import SwiftUI
import FirebaseFirestore

/// Centralized dependency injection with in-app Mock/Firebase toggle
@Observable
final class ServiceContainer {
    static let shared = ServiceContainer()

    var useMockServices: Bool {
        didSet {
            UserDefaults.standard.set(useMockServices, forKey: "useMockServices")
        }
    }

    var eventService: EventServiceProtocol {
        useMockServices ? mockEventService : firebaseEventService
    }

    var factionService: FactionServiceProtocol {
        useMockServices ? mockFactionService : firebaseFactionService
    }

    private let mockEventService = MockEventService()
    private let mockFactionService = MockFactionService()
    private let firebaseEventService = EventFirebaseService()
    private let firebaseFactionService = FactionFirebaseService()

    private init() {
        self.useMockServices = UserDefaults.standard.object(forKey: "useMockServices") as? Bool ?? true
    }

    // MARK: - Seed Firestore

    /// Push SampleData into Firestore (for development)
    func seedFirestore() async throws {
        let db = FirebaseManager.shared.db

        // Seed events
        for event in SampleData.events {
            try db.collection("events").document(event.id).setData(from: event)
        }

        // Seed factions
        for faction in SampleData.factions {
            try db.collection("factions").document(faction.id).setData(from: faction)
        }

        // Seed intel reports
        for report in SampleData.intelReports {
            try db.collection("intelReports").document(report.id).setData(from: report)
        }

        // Seed regions
        for region in SampleData.regions {
            try db.collection("regions").document(region.id).setData(from: region)
        }
    }
}
