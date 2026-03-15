import Foundation
import Combine

protocol FactionServiceProtocol {
    /// Fetch all factions
    func fetchFactions() async throws -> [Faction]

    /// Listen to real-time faction updates
    func observeFactions() -> AnyPublisher<[Faction], Error>

    /// Fetch a single faction by ID
    func fetchFaction(id: String) async throws -> Faction

    /// Search factions by name
    func searchFactions(query: String) async throws -> [Faction]
}
