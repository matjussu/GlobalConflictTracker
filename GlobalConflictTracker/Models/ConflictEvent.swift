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
}
