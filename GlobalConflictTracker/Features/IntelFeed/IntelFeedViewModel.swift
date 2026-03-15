import Foundation
import Observation
import Combine

@Observable
final class IntelFeedViewModel {

    var reports: [IntelReport] = []
    var selectedCategory: IntelCategory? = nil
    var isLoading = true
    var errorMessage: String?

    private let eventService: EventServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var optimisticallyReadIDs: Set<String> = []

    init(eventService: EventServiceProtocol = ServiceContainer.shared.eventService) {
        self.eventService = eventService
        startObserving()
    }

    var filteredReports: [IntelReport] {
        guard let category = selectedCategory else { return reports }
        return reports.filter { $0.category == category }
    }

    var isEmpty: Bool {
        !isLoading && filteredReports.isEmpty
    }

    func selectCategory(_ category: IntelCategory?) {
        selectedCategory = category
        HapticManager.selection()
    }

    func loadReports() async {
        errorMessage = nil
        do {
            var fetched = try await eventService.fetchIntelReports(category: nil)
            mergeOptimisticReadState(&fetched)
            reports = fetched
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func markAsRead(_ report: IntelReport) async {
        guard !report.isRead else { return }
        optimisticallyReadIDs.insert(report.id)
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            reports[index].isRead = true
        }
        try? await eventService.markAsRead(reportID: report.id)
    }

    private func startObserving() {
        eventService.observeIntelReports()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reports in
                    guard let self else { return }
                    var merged = reports
                    self.mergeOptimisticReadState(&merged)
                    self.reports = merged
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }

    private func mergeOptimisticReadState(_ reports: inout [IntelReport]) {
        for i in reports.indices {
            if optimisticallyReadIDs.contains(reports[i].id) {
                reports[i].isRead = true
            }
        }
        // Clean up IDs that Firestore has confirmed
        optimisticallyReadIDs = optimisticallyReadIDs.filter { id in
            reports.first(where: { $0.id == id })?.isRead != true
        }
    }
}
