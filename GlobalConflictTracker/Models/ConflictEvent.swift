import Foundation
import CoreLocation

struct ConflictEvent: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var summary: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var severity: Severity
    var eventType: EventType
    var factionIDs: [String]
    var sourceReliability: SourceReliability
    var tags: [String]
    var imageURL: String?
    var isRead: Bool = false

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Impact zone radius in meters, based on severity
    var impactRadius: CLLocationDistance {
        switch severity {
        case .critical: 150_000
        case .warning: 80_000
        case .low: 40_000
        }
    }

}
