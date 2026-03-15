import Foundation
import Combine

/// Mock implementation for SwiftUI previews and testing
final class MockEventService: EventServiceProtocol {

    var mockEvents: [ConflictEvent] = SampleData.events
    var mockReports: [IntelReport] = SampleData.intelReports
    var simulateError = false
    var simulateDelay: TimeInterval = 0

    func fetchEvents() async throws -> [ConflictEvent] {
        if simulateDelay > 0 {
            try await Task.sleep(for: .seconds(simulateDelay))
        }
        if simulateError { throw MockError.networkFailure }
        return mockEvents
    }

    func observeEvents() -> AnyPublisher<[ConflictEvent], Error> {
        Just(mockEvents)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEvent(id: String) async throws -> ConflictEvent {
        if simulateError { throw MockError.networkFailure }
        guard let event = mockEvents.first(where: { $0.id == id }) else {
            throw MockError.notFound
        }
        return event
    }

    func fetchIntelReports(category: IntelCategory?) async throws -> [IntelReport] {
        if simulateDelay > 0 {
            try await Task.sleep(for: .seconds(simulateDelay))
        }
        if simulateError { throw MockError.networkFailure }
        guard let category else { return mockReports }
        return mockReports.filter { $0.category == category }
    }

    func observeIntelReports() -> AnyPublisher<[IntelReport], Error> {
        Just(mockReports)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func markAsRead(reportID: String) async throws {
        if let index = mockReports.firstIndex(where: { $0.id == reportID }) {
            mockReports[index].isRead = true
        }
    }
}

enum MockError: LocalizedError {
    case networkFailure
    case notFound

    var errorDescription: String? {
        switch self {
        case .networkFailure: "Unable to reach tactical servers."
        case .notFound: "Resource not found."
        }
    }
}
