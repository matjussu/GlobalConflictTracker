import Foundation
import CoreLocation

struct GeoPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct TrajectoryData: Codable, Hashable {
    let origin: GeoPoint
    let destination: GeoPoint
    let originLabel: String
    let destinationLabel: String
    let weaponType: String?
    let arcHeight: Double
    let isActive: Bool
}

struct MovementPathData: Codable, Hashable {
    let waypoints: [GeoPoint]
    let originLabel: String
    let destinationLabel: String?
    let assetType: String?
    let progressFraction: Double
}

struct ZoneData: Codable, Hashable {
    let boundary: [GeoPoint]
    let radiusMeters: Double?
    let zoneLabel: String
    let fillOpacity: Double
    let isActive: Bool
}

struct ConnectionData: Codable, Hashable {
    let source: GeoPoint
    let target: GeoPoint
    let sourceLabel: String
    let targetLabel: String
    let connectionType: String
}
