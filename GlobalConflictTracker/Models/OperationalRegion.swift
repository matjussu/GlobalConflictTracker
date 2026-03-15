import Foundation
import CoreLocation

struct OperationalRegion: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var centerLatitude: Double
    var centerLongitude: Double
    var zoomLevel: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }
}
