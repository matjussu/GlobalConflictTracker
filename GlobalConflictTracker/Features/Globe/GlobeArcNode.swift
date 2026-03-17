import SceneKit
import UIKit

/// SCNNode representing a trajectory arc on the globe (missile strike, airstrike, etc.).
/// Rendered as a line strip geometry with emissive material for glow effect.
final class GlobeArcNode: SCNNode {
    let eventID: String

    init(event: ConflictEvent, trajectory: TrajectoryData, converter: GlobeCoordinateConverter) {
        self.eventID = event.id
        super.init()

        self.name = "arc-\(event.id)"

        let origin = converter.position(
            latitude: trajectory.origin.latitude,
            longitude: trajectory.origin.longitude
        )
        let destination = converter.position(
            latitude: trajectory.destination.latitude,
            longitude: trajectory.destination.longitude
        )

        let arcHeight = Float(trajectory.arcHeight) + 0.1
        let points = converter.arcPoints(
            from: origin,
            to: destination,
            arcHeight: arcHeight,
            segments: 40
        )

        guard points.count >= 2 else { return }

        // Build line strip geometry
        let source = SCNGeometrySource(vertices: points)

        var indices: [Int32] = []
        indices.reserveCapacity((points.count - 1) * 2)
        for i in 0..<(points.count - 1) {
            indices.append(Int32(i))
            indices.append(Int32(i + 1))
        }

        let element = SCNGeometryElement(
            indices: indices,
            primitiveType: .line
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        let arcColor = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0)
        material.diffuse.contents = arcColor
        material.emission.contents = arcColor
        material.lightingModel = .constant
        material.isDoubleSided = true
        geometry.materials = [material]

        self.geometry = geometry

        // Add small sphere markers at origin and destination
        addEndpointMarker(at: origin, label: trajectory.originLabel, color: arcColor)
        addEndpointMarker(at: destination, label: trajectory.destinationLabel, color: arcColor)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addEndpointMarker(at position: SCNVector3, label: String, color: UIColor) {
        let sphere = SCNSphere(radius: 0.008)
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(0.5)
        material.emission.contents = color.withAlphaComponent(0.3)
        material.lightingModel = .constant
        sphere.materials = [material]

        let node = SCNNode(geometry: sphere)
        node.position = position
        addChildNode(node)
    }
}
