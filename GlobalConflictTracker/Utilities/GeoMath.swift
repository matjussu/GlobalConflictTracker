import Foundation
import CoreLocation

struct GeoMath {

    /// Generates intermediate points along a great-circle arc with visual curvature.
    /// The `arcHeight` parameter (0.0–1.0) controls the perpendicular offset that creates
    /// the visible arc above the Earth's surface.
    static func arcPoints(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        segments: Int = 50,
        arcHeight: Double = 0.15
    ) -> [CLLocationCoordinate2D] {
        var points: [CLLocationCoordinate2D] = []

        let lat1 = origin.latitude.radians
        let lon1 = origin.longitude.radians
        let lat2 = destination.latitude.radians
        let lon2 = destination.longitude.radians

        // Great-circle distance (angular)
        let d = acos(
            sin(lat1) * sin(lat2) +
            cos(lat1) * cos(lat2) * cos(lon2 - lon1)
        )

        guard d > 0 else { return [origin, destination] }

        // Perpendicular bearing offset for arc curvature
        let midLat = (origin.latitude + destination.latitude) / 2.0
        let midLon = (origin.longitude + destination.longitude) / 2.0
        let perpBearing = bearing(from: origin, to: destination) + 90.0

        for i in 0...segments {
            let fraction = Double(i) / Double(segments)

            // Spherical linear interpolation (slerp)
            let a = sin((1.0 - fraction) * d) / sin(d)
            let b = sin(fraction * d) / sin(d)

            let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
            let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
            let z = a * sin(lat1) + b * sin(lat2)

            var lat = atan2(z, sqrt(x * x + y * y))
            var lon = atan2(y, x)

            // Apply arc height offset (sinusoidal curve peaking at midpoint)
            let heightOffset = arcHeight * sin(fraction * .pi)
            let distanceFromCenter = sqrt(
                pow(lat.degrees - midLat, 2) + pow(lon.degrees - midLon, 2)
            )
            let maxDistance = sqrt(
                pow(origin.latitude - midLat, 2) + pow(origin.longitude - midLon, 2)
            )

            // Offset perpendicular to the great-circle path
            let offsetMagnitude = heightOffset * max(d.degrees, 5.0)
            lat += (offsetMagnitude * cos(perpBearing.radians)).radians
            lon += (offsetMagnitude * sin(perpBearing.radians) / cos(lat)).radians

            points.append(CLLocationCoordinate2D(
                latitude: lat.degrees,
                longitude: lon.degrees
            ))
        }

        return points
    }

    /// Calculates the initial bearing (in degrees) from one coordinate to another.
    static func bearing(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = origin.latitude.radians
        let lat2 = destination.latitude.radians
        let dLon = (destination.longitude - origin.longitude).radians

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let bearing = atan2(y, x).degrees
        return (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    /// Interpolates a position along an array of coordinates at a given fraction (0.0–1.0).
    static func interpolate(
        along points: [CLLocationCoordinate2D],
        at fraction: Double
    ) -> CLLocationCoordinate2D {
        guard points.count >= 2 else {
            return points.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        let clampedFraction = min(max(fraction, 0.0), 1.0)
        let totalSegments = Double(points.count - 1)
        let exactIndex = clampedFraction * totalSegments

        let lowerIndex = Int(exactIndex)
        let upperIndex = min(lowerIndex + 1, points.count - 1)
        let segmentFraction = exactIndex - Double(lowerIndex)

        let p1 = points[lowerIndex]
        let p2 = points[upperIndex]

        return CLLocationCoordinate2D(
            latitude: p1.latitude + (p2.latitude - p1.latitude) * segmentFraction,
            longitude: p1.longitude + (p2.longitude - p1.longitude) * segmentFraction
        )
    }

    /// Computes the centroid of a polygon defined by an array of coordinates.
    static func centroid(of points: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !points.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        let sumLat = points.reduce(0.0) { $0 + $1.latitude }
        let sumLon = points.reduce(0.0) { $0 + $1.longitude }
        return CLLocationCoordinate2D(
            latitude: sumLat / Double(points.count),
            longitude: sumLon / Double(points.count)
        )
    }
}

// MARK: - Angle Conversions

private extension Double {
    var radians: Double { self * .pi / 180.0 }
    var degrees: Double { self * 180.0 / .pi }
}
