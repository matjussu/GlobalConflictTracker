import SwiftUI
import Combine
import MapKit
import CoreLocation

struct EventConnection: Identifiable {
    let from: CLLocationCoordinate2D
    let to: CLLocationCoordinate2D
    let id: String
}

@Observable
final class TacticalMapViewModel {

    var events: [ConflictEvent] = []
    var selectedEvent: ConflictEvent?
    var isLoading = true
    var errorMessage: String?
    var searchText = ""
    var showAlert = false
    var mapStyleOption: MapStyleOption = .tactical

    enum MapStyleOption: String, CaseIterable {
        case tactical = "Tactical"
        case satellite = "Satellite"
        case hybrid = "Hybrid"
        case terrain = "Terrain"

        var mapStyle: MapStyle {
            switch self {
            case .tactical:
                .standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false)
            case .satellite:
                .imagery(elevation: .realistic)
            case .hybrid:
                .hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false)
            case .terrain:
                .standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false)
            }
        }

        var icon: String {
            switch self {
            case .tactical: "shield.fill"
            case .satellite: "globe.americas.fill"
            case .hybrid: "map.fill"
            case .terrain: "mountain.2.fill"
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

    init(eventService: EventServiceProtocol = ServiceContainer.shared.eventService) {
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

    /// Connections between events sharing common factions
    var eventConnections: [EventConnection] {
        var connections: [EventConnection] = []
        let events = filteredEvents
        for i in 0..<events.count {
            for j in (i + 1)..<events.count {
                let shared = events[i].factionIDs.filter { events[j].factionIDs.contains($0) }
                if !shared.isEmpty {
                    connections.append(EventConnection(
                        from: events[i].coordinate,
                        to: events[j].coordinate,
                        id: "\(events[i].id)-\(events[j].id)"
                    ))
                }
            }
        }
        return connections
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
