import Foundation
import Observation
import Combine

@Observable
final class FactionProfileViewModel {

    var faction: Faction
    var recentEvents: [ConflictEvent] = []
    var isLoading = false

    private let eventService: EventServiceProtocol

    init(
        faction: Faction,
        eventService: EventServiceProtocol = ServiceContainer.shared.eventService
    ) {
        self.faction = faction
        self.eventService = eventService
    }

    func loadRecentEvents() async {
        isLoading = true
        var events: [ConflictEvent] = []
        for eventID in faction.recentEventIDs {
            if let event = try? await eventService.fetchEvent(id: eventID) {
                events.append(event)
            }
        }
        recentEvents = events
        isLoading = false
    }
}
