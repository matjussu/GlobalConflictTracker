import Foundation
import Observation
import Combine

@Observable
final class FactionsDirectoryViewModel {

    var factions: [Faction] = []
    var searchText = ""
    var isLoading = true
    var errorMessage: String?
    var selectedFactionID: String?
    var showFilterSheet = false

    // Filter/sort options
    var sortBy: SortOption = .name
    var filterByType: FactionType?

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case personnel = "Personnel"
        case activity = "Activity"
    }

    private let factionService: FactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(factionService: FactionServiceProtocol = FactionFirebaseService()) {
        self.factionService = factionService
        startObserving()
    }

    var filteredFactions: [Faction] {
        var result = factions

        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Type filter
        if let filterByType {
            result = result.filter { $0.type == filterByType }
        }

        // Sort
        switch sortBy {
        case .name:
            result.sort { $0.name < $1.name }
        case .personnel:
            result.sort { $0.personnelCount > $1.personnelCount }
        case .activity:
            result.sort { $0.status.isActive && !$1.status.isActive }
        }

        return result
    }

    var isEmpty: Bool {
        !isLoading && filteredFactions.isEmpty
    }

    func loadFactions() async {
        isLoading = true
        errorMessage = nil
        do {
            factions = try await factionService.fetchFactions()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func resetFilters() {
        searchText = ""
        filterByType = nil
        sortBy = .name
    }

    private func startObserving() {
        factionService.observeFactions()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] factions in
                    self?.factions = factions
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
}
