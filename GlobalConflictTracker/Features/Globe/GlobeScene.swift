import SceneKit
import UIKit

/// Builds and manages the SceneKit scene for the 3D interactive globe.
/// Contains the dot-matrix globe, atmosphere glow, event markers, and trajectory arcs.
final class GlobeScene {
    let scene: SCNScene
    let cameraNode: SCNNode
    let globePivotNode: SCNNode

    private let converter: GlobeCoordinateConverter
    private let markersContainer: SCNNode
    private let arcsContainer: SCNNode
    private var markerNodes: [String: SCNNode] = [:]
    private var arcNodes: [String: SCNNode] = [:]

    init(radius: Float = 1.0) {
        self.converter = GlobeCoordinateConverter(radius: radius)
        self.scene = SCNScene()
        self.globePivotNode = SCNNode()
        self.markersContainer = SCNNode()
        self.arcsContainer = SCNNode()
        self.cameraNode = SCNNode()

        globePivotNode.name = "globePivot"
        markersContainer.name = "markers"
        arcsContainer.name = "arcs"

        globePivotNode.addChildNode(markersContainer)
        globePivotNode.addChildNode(arcsContainer)

        // Build scene
        let dotGlobe = buildDotGlobe()
        globePivotNode.addChildNode(dotGlobe)

        let atmosphere = buildAtmosphere()
        globePivotNode.addChildNode(atmosphere)

        scene.rootNode.addChildNode(globePivotNode)

        buildCamera()
        buildLighting()

        // Set initial rotation to show Europe/Africa
        globePivotNode.eulerAngles.y = -0.3

        scene.background.contents = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
    }

    // MARK: - Globe Construction

    private func buildDotGlobe() -> SCNNode {
        let candidateCount = 25_000
        let candidates = converter.fibonacciSpherePoints(count: candidateCount)

        // Load world map
        guard let uiImage = UIImage(named: "world_map_bw"),
              let cgImage = uiImage.cgImage else {
            // Fallback: render all points if map not found
            return buildPointNode(from: candidates)
        }

        // Filter to land-only points
        var landPoints: [SCNVector3] = []
        landPoints.reserveCapacity(candidateCount / 3)

        for point in candidates {
            let coord = converter.coordinate(from: point)
            if converter.isLand(
                latitude: coord.latitude,
                longitude: coord.longitude,
                mapImage: cgImage
            ) {
                landPoints.append(point)
            }
        }

        return buildPointNode(from: landPoints)
    }

    private func buildPointNode(from points: [SCNVector3]) -> SCNNode {
        let source = SCNGeometrySource(vertices: points)

        var indices: [Int32] = []
        indices.reserveCapacity(points.count)
        for i in 0..<points.count {
            indices.append(Int32(i))
        }

        let element = SCNGeometryElement(
            indices: indices,
            primitiveType: .point
        )
        element.pointSize = 2.5
        element.minimumPointScreenSpaceRadius = 1.5
        element.maximumPointScreenSpaceRadius = 5.0

        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(white: 0.55, alpha: 0.85)
        material.emission.contents = UIColor(red: 0.1, green: 0.3, blue: 0.4, alpha: 0.3)
        material.lightingModel = .constant
        material.isDoubleSided = true
        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        node.name = "dotGlobe"
        return node
    }

    private func buildAtmosphere() -> SCNNode {
        let atmosphereSphere = SCNSphere(radius: CGFloat(converter.radius * 1.03))
        atmosphereSphere.segmentCount = 64

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = true
        material.blendMode = .add

        // Fresnel edge glow via shader modifier
        material.shaderModifiers = [
            .fragment: """
                float NdotV = abs(dot(normalize(_surface.normal), normalize(_surface.view)));
                float fresnel = pow(1.0 - NdotV, 3.0);
                _output.color = float4(0.08, 0.35, 0.55, fresnel * 0.25);
                """
        ]

        atmosphereSphere.materials = [material]

        let node = SCNNode(geometry: atmosphereSphere)
        node.name = "atmosphere"
        node.renderingOrder = -1
        return node
    }

    private func buildCamera() {
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 100

        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 3.5)
        cameraNode.name = "camera"

        scene.rootNode.addChildNode(cameraNode)
    }

    private func buildLighting() {
        // Ambient
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 30
        ambientLight.color = UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)

        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        ambientNode.name = "ambientLight"
        scene.rootNode.addChildNode(ambientNode)

        // Directional
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 80
        directionalLight.color = UIColor(red: 0.27, green: 0.33, blue: 0.40, alpha: 1.0)
        directionalLight.castsShadow = false

        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(2, 3, 4)
        directionalNode.look(at: SCNVector3.zero)
        directionalNode.name = "directionalLight"
        scene.rootNode.addChildNode(directionalNode)
    }

    // MARK: - Dynamic Updates

    func updateMarkers(events: [ConflictEvent]) {
        let currentIDs = Set(events.map(\.id))
        let existingIDs = Set(markerNodes.keys)

        // Remove stale markers
        for id in existingIDs.subtracting(currentIDs) {
            markerNodes[id]?.removeFromParentNode()
            markerNodes.removeValue(forKey: id)
        }

        // Add new markers
        for event in events where !existingIDs.contains(event.id) {
            let markerNode = GlobeMarkerNode(event: event, converter: converter)
            markersContainer.addChildNode(markerNode)
            markerNodes[event.id] = markerNode
        }
    }

    func updateArcs(events: [ConflictEvent]) {
        let currentIDs = Set(events.map(\.id))
        let existingIDs = Set(arcNodes.keys)

        // Remove stale arcs
        for id in existingIDs.subtracting(currentIDs) {
            arcNodes[id]?.removeFromParentNode()
            arcNodes.removeValue(forKey: id)
        }

        // Add new arcs
        for event in events where !existingIDs.contains(event.id) {
            if case .trajectory(let data) = event.visualization {
                let arcNode = GlobeArcNode(
                    event: event,
                    trajectory: data,
                    converter: converter
                )
                arcsContainer.addChildNode(arcNode)
                arcNodes[event.id] = arcNode
            }
        }
    }

    // MARK: - Auto-Rotation

    func startAutoRotation() {
        let rotation = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 90)
        )
        globePivotNode.runAction(rotation, forKey: "autoRotate")
    }

    func stopAutoRotation() {
        globePivotNode.removeAction(forKey: "autoRotate")
    }

    // MARK: - Hit Testing

    /// Walk up the node hierarchy to find an event marker and return its ID.
    func eventID(for node: SCNNode) -> String? {
        var current: SCNNode? = node
        while let n = current {
            if let name = n.name, name.hasPrefix("event-") {
                return String(name.dropFirst(6))
            }
            current = n.parent
        }
        return nil
    }
}
