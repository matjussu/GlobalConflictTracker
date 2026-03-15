import SwiftUI
import Combine
import MapKit

@Observable
final class TacticalMapViewModel {

    var events: [ConflictEvent] = []
    var selectedEvent: ConflictEvent?
    var isLoading = true
    var errorMessage: String?
    var searchText = ""
    var showAlert = false
    var mapStyleOption: MapStyleOption = .satellite

    enum MapStyleOption: String, CaseIterable {
        case satellite = "Satellite"
        case hybrid = "Hybrid"
        case standard = "Standard"

        var mapStyle: MapStyle {
            switch self {
            case .satellite: .imagery(elevation: .flat)
            case .hybrid: .hybrid(elevation: .flat, pointsOfInterest: .excludingAll)
            case .standard: .standard(elevation: .flat, pointsOfInterest: .excludingAll)
            }
        }

        var icon: String {
            switch self {
            case .satellite: "globe.americas.fill"
            case .hybrid: "map.fill"
            case .standard: "map"
            }
        }
    }

    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.0, longitude: 40.0),
            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        )
    )

    private let eventService: EventServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(eventService: EventServiceProtocol = EventFirebaseService()) {
        self.eventService = eventService
        startObserving()
    }

    var filteredEvents: [ConflictEvent] {
        guard !searchText.isEmpty else { return events }
        return events.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.summary.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    /// Most critical unread event for the bottom sheet alert
    var latestCriticalEvent: ConflictEvent? {
        events.first { $0.severity == .critical && !$0.isRead }
    }

    func selectEvent(_ event: ConflictEvent) {
        selectedEvent = event
        showAlert = true
        HapticManager.impact(.medium)
    }

    func dismissAlert() {
        withAnimation {
            showAlert = false
        }
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            events = try await eventService.fetchEvents()
            isLoading = false
            if latestCriticalEvent != nil {
                showAlert = true
                HapticManager.notification(.warning)
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
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
