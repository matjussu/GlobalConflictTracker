import Foundation
import Combine
import FirebaseFirestore

final class FactionFirebaseService: FactionServiceProtocol {

    private let manager = FirebaseManager.shared

    func fetchFactions() async throws -> [Faction] {
        let snapshot = try await manager.factionsCollection
            .order(by: "name")
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: Faction.self)
        }
    }

    func observeFactions() -> AnyPublisher<[Faction], Error> {
        let subject = PassthroughSubject<[Faction], Error>()

        manager.factionsCollection
            .order(by: "name")
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                guard let snapshot else { return }

                let factions = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Faction.self)
                }
                subject.send(factions)
            }

        return subject.eraseToAnyPublisher()
    }

    func fetchFaction(id: String) async throws -> Faction {
        let doc = try await manager.factionsCollection.document(id).getDocument()
        return try doc.data(as: Faction.self)
    }

    func searchFactions(query: String) async throws -> [Faction] {
        let allFactions = try await fetchFactions()
        guard !query.isEmpty else { return allFactions }
        return allFactions.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
