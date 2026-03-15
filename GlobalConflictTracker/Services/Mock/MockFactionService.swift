import Foundation
import Combine

/// Mock implementation for SwiftUI previews and testing
final class MockFactionService: FactionServiceProtocol {

    var mockFactions: [Faction] = SampleData.factions
    var simulateError = false

    func fetchFactions() async throws -> [Faction] {
        if simulateError { throw MockError.networkFailure }
        return mockFactions
    }

    func observeFactions() -> AnyPublisher<[Faction], Error> {
        Just(mockFactions)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchFaction(id: String) async throws -> Faction {
        if simulateError { throw MockError.networkFailure }
        guard let faction = mockFactions.first(where: { $0.id == id }) else {
            throw MockError.notFound
        }
        return faction
    }

    func searchFactions(query: String) async throws -> [Faction] {
        if simulateError { throw MockError.networkFailure }
        guard !query.isEmpty else { return mockFactions }
        return mockFactions.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
