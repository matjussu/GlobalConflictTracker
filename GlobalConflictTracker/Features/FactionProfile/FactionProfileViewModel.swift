import Foundation
import Observation
import Combine

@Observable
final class FactionProfileViewModel {

    var faction: Faction
    var recentEvents: [ConflictEvent] = []
    var isLoading = false

    private let eventService: EventServiceProtocol
    private let factionService: FactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        faction: Faction,
        eventService: EventServiceProtocol = ServiceContainer.shared.eventService,
        factionService: FactionServiceProtocol = ServiceContainer.shared.factionService
    ) {
        self.faction = faction
        self.eventService = eventService
        self.factionService = factionService
        startObservingFaction()
    }

    func loadRecentEvents() async {
        isLoading = true
        let idOrder = faction.recentEventIDs
        recentEvents = await withTaskGroup(of: ConflictEvent?.self) { group in
            for eventID in idOrder {
                group.addTask { [eventService] in
                    try? await eventService.fetchEvent(id: eventID)
                }
            }
            var results: [ConflictEvent] = []
            for await event in group {
                if let event { results.append(event) }
            }
            return results
        }
        // Preserve original ordering
        recentEvents.sort { a, b in
            (idOrder.firstIndex(of: a.id) ?? .max) < (idOrder.firstIndex(of: b.id) ?? .max)
        }
        isLoading = false
    }

    private func startObservingFaction() {
        factionService.observeFaction(id: faction.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] updatedFaction in
                    self?.faction = updatedFaction
                }
            )
            .store(in: &cancellables)
    }
}
