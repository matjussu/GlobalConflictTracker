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

    init(eventService: EventServiceProtocol = EventFirebaseService()) {
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
        isLoading = true
        errorMessage = nil
        do {
            reports = try await eventService.fetchIntelReports(category: nil)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func markAsRead(_ report: IntelReport) async {
        guard !report.isRead else { return }
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
                    self?.reports = reports
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
}
