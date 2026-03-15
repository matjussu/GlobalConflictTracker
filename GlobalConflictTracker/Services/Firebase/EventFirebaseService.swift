import Foundation
import Combine
import FirebaseFirestore

final class EventFirebaseService: EventServiceProtocol {

    private let manager = FirebaseManager.shared

    func fetchEvents() async throws -> [ConflictEvent] {
        let snapshot = try await manager.eventsCollection
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: ConflictEvent.self)
        }
    }

    func observeEvents() -> AnyPublisher<[ConflictEvent], Error> {
        let subject = PassthroughSubject<[ConflictEvent], Error>()

        manager.eventsCollection
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                guard let snapshot else { return }

                let events = snapshot.documents.compactMap { doc in
                    try? doc.data(as: ConflictEvent.self)
                }
                subject.send(events)
            }

        return subject.eraseToAnyPublisher()
    }

    func fetchEvent(id: String) async throws -> ConflictEvent {
        let doc = try await manager.eventsCollection.document(id).getDocument()
        return try doc.data(as: ConflictEvent.self)
    }

    func fetchIntelReports(category: IntelCategory?) async throws -> [IntelReport] {
        var query: Query = manager.intelReportsCollection
            .order(by: "timestamp", descending: true)

        if let category {
            query = query.whereField("category", isEqualTo: category.rawValue)
        }

        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: IntelReport.self)
        }
    }

    func observeIntelReports() -> AnyPublisher<[IntelReport], Error> {
        let subject = PassthroughSubject<[IntelReport], Error>()

        manager.intelReportsCollection
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                guard let snapshot else { return }

                let reports = snapshot.documents.compactMap { doc in
                    try? doc.data(as: IntelReport.self)
                }
                subject.send(reports)
            }

        return subject.eraseToAnyPublisher()
    }

    func markAsRead(reportID: String) async throws {
        try await manager.intelReportsCollection
            .document(reportID)
            .updateData(["isRead": true])
    }
}
