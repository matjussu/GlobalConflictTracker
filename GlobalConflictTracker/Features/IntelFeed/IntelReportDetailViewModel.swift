import Foundation
import Observation

@Observable
final class IntelReportDetailViewModel {

    let report: IntelReport
    var relatedEvent: ConflictEvent?
    var isLoadingEvent = false

    private let eventService: EventServiceProtocol

    init(
        report: IntelReport,
        eventService: EventServiceProtocol = ServiceContainer.shared.eventService
    ) {
        self.report = report
        self.eventService = eventService
    }

    func loadRelatedEvent() async {
        guard let eventID = report.relatedEventID else { return }
        isLoadingEvent = true
        relatedEvent = try? await eventService.fetchEvent(id: eventID)
        isLoadingEvent = false
    }
}
