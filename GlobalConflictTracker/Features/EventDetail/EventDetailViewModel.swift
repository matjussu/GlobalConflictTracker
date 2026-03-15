import Foundation
import Observation

@Observable
final class EventDetailViewModel {

    var event: ConflictEvent
    var relatedFactions: [Faction] = []
    var isLoading = false

    private let eventService: EventServiceProtocol
    private let factionService: FactionServiceProtocol

    init(
        event: ConflictEvent,
        eventService: EventServiceProtocol = EventFirebaseService(),
        factionService: FactionServiceProtocol = FactionFirebaseService()
    ) {
        self.event = event
        self.eventService = eventService
        self.factionService = factionService
    }

    func loadRelatedFactions() async {
        isLoading = true
        var factions: [Faction] = []
        for factionID in event.factionIDs {
            if let faction = try? await factionService.fetchFaction(id: factionID) {
                factions.append(faction)
            }
        }
        relatedFactions = factions
        isLoading = false
    }
}
