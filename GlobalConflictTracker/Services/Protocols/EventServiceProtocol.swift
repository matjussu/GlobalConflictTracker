import Foundation
import Combine

protocol EventServiceProtocol {
    /// Fetch all conflict events
    func fetchEvents() async throws -> [ConflictEvent]

    /// Listen to real-time event updates
    func observeEvents() -> AnyPublisher<[ConflictEvent], Error>

    /// Fetch a single event by ID
    func fetchEvent(id: String) async throws -> ConflictEvent

    /// Fetch intel reports, optionally filtered by category
    func fetchIntelReports(category: IntelCategory?) async throws -> [IntelReport]

    /// Listen to real-time intel report updates
    func observeIntelReports() -> AnyPublisher<[IntelReport], Error>

    /// Mark an intel report as read
    func markAsRead(reportID: String) async throws
}
