import Foundation
import Observation
import Combine

@Observable
final class GlobeViewModel {

    var events: [ConflictEvent] = []
    var selectedEvent: ConflictEvent?
    var isLoading = true
    var errorMessage: String?

    private let eventService: EventServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(eventService: EventServiceProtocol = ServiceContainer.shared.eventService) {
        self.eventService = eventService
        startObserving()
    }

    var trajectoryEvents: [ConflictEvent] {
        events.filter {
            if case .trajectory = $0.visualization { return true }
            return false
        }
    }

    func loadEvents() async {
        errorMessage = nil
        do {
            events = try await eventService.fetchEvents()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func selectEvent(id: String) {
        selectedEvent = events.first { $0.id == id }
        HapticManager.impact(.medium)
    }

    func clearSelection() {
        selectedEvent = nil
    }

    private func startObserving() {
        eventService.observeEvents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] events in
                    self?.events = events
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
}
