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
    var visualization: MapVisualization?
    var subtype: EventSubtype?

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

    /// Short label for always-visible map display (e.g. "MISSILE → ISFAHAN")
    var compactLabel: String {
        if let subtype {
            switch visualization {
            case .trajectory(let data):
                return "\(subtype.label) → \(data.destinationLabel.components(separatedBy: ",").first ?? data.destinationLabel)"
            case .movementPath(let data):
                if let dest = data.destinationLabel {
                    return "\(subtype.label) → \(dest)"
                }
                return subtype.label
            case .zone(let data):
                return data.zoneLabel
            case .connection(let data):
                return "\(subtype.label) → \(data.targetLabel.components(separatedBy: ",").first ?? data.targetLabel)"
            case .point, .none:
                return subtype.label
            }
        }
        return title.uppercased()
    }

}
