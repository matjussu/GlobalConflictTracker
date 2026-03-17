import SceneKit
import UIKit

struct GlobeCoordinateConverter {
    let radius: Float

    /// Convert latitude/longitude (degrees) to a 3D position on the sphere surface.
    func position(latitude: Double, longitude: Double) -> SCNVector3 {
        let latRad = Float(latitude * .pi / 180.0)
        let lonRad = Float(longitude * .pi / 180.0)

        let x = radius * cos(latRad) * cos(lonRad)
        let y = radius * sin(latRad)
        let z = -radius * cos(latRad) * sin(lonRad)

        return SCNVector3(x, y, z)
    }

    /// Convert a 3D position back to latitude/longitude (degrees).
    func coordinate(from position: SCNVector3) -> (latitude: Double, longitude: Double) {
        let lat = asin(position.y / radius)
        let lon = atan2(-position.z, position.x)
        return (
            latitude: Double(lat) * 180.0 / .pi,
            longitude: Double(lon) * 180.0 / .pi
        )
    }

    /// Generate uniformly distributed points on the sphere using Fibonacci spiral.
    func fibonacciSpherePoints(count: Int) -> [SCNVector3] {
        var points: [SCNVector3] = []
        points.reserveCapacity(count)

        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))

        for i in 0..<count {
            let y = 1.0 - (Float(i) / Float(count - 1)) * 2.0 // y from 1 to -1
            let radiusAtY = sqrt(1.0 - y * y)
            let theta = goldenAngle * Float(i)

            let x = cos(theta) * radiusAtY
            let z = sin(theta) * radiusAtY

            points.append(SCNVector3(x * radius, y * radius, z * radius))
        }

        return points
    }

    /// Sample the world map texture at a given lat/lon. Returns true if pixel is land (bright).
    func isLand(latitude: Double, longitude: Double, mapImage: CGImage) -> Bool {
        let width = mapImage.width
        let height = mapImage.height

        // Convert lat/lon to UV coordinates
        let u = (longitude + 180.0) / 360.0
        let v = (90.0 - latitude) / 180.0

        let px = Int(u * Double(width)) % width
        let py = min(Int(v * Double(height)), height - 1)

        guard let dataProvider = mapImage.dataProvider,
              let data = dataProvider.data,
              let ptr = CFDataGetBytePtr(data) else {
            return false
        }

        let bytesPerRow = mapImage.bytesPerRow
        let bytesPerPixel = mapImage.bitsPerPixel / 8

        let offset = py * bytesPerRow + px * bytesPerPixel
        let pixelValue = ptr[offset]

        return pixelValue > 128
    }

    /// Generate 3D Bezier arc points between two surface positions.
    /// The arc rises above the sphere by `arcHeight` (relative to radius).
    func arcPoints(
        from origin: SCNVector3,
        to destination: SCNVector3,
        arcHeight: Float = 0.2,
        segments: Int = 40
    ) -> [SCNVector3] {
        // Midpoint on the sphere surface (normalized)
        let midX = (origin.x + destination.x) / 2.0
        let midY = (origin.y + destination.y) / 2.0
        let midZ = (origin.z + destination.z) / 2.0

        let midLength = sqrt(midX * midX + midY * midY + midZ * midZ)
        guard midLength > 0 else { return [origin, destination] }

        // Control point: midpoint projected onto sphere then elevated
        let controlScale = (radius + radius * arcHeight) / midLength
        let control = SCNVector3(
            midX * controlScale,
            midY * controlScale,
            midZ * controlScale
        )

        // Quadratic Bezier: B(t) = (1-t)²·P1 + 2(1-t)t·C + t²·P2
        var points: [SCNVector3] = []
        points.reserveCapacity(segments + 1)

        for i in 0...segments {
            let t = Float(i) / Float(segments)
            let u = 1.0 - t

            let x = u * u * origin.x + 2.0 * u * t * control.x + t * t * destination.x
            let y = u * u * origin.y + 2.0 * u * t * control.y + t * t * destination.y
            let z = u * u * origin.z + 2.0 * u * t * control.z + t * t * destination.z

            points.append(SCNVector3(x, y, z))
        }

        return points
    }
}
