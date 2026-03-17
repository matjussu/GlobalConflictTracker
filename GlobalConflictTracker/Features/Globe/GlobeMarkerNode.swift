import SceneKit
import UIKit

/// SCNNode representing a conflict event marker on the globe surface.
/// Colored by severity, pulses for critical events, shows a billboard label.
final class GlobeMarkerNode: SCNNode {
    let eventID: String
    let severity: Severity

    init(event: ConflictEvent, converter: GlobeCoordinateConverter) {
        self.eventID = event.id
        self.severity = event.severity
        super.init()

        self.name = "event-\(event.id)"
        self.position = converter.position(latitude: event.latitude, longitude: event.longitude)

        // Marker sphere
        let markerRadius: CGFloat = event.severity == .critical ? 0.02 : 0.015
        let sphere = SCNSphere(radius: markerRadius)

        let material = SCNMaterial()
        material.diffuse.contents = uiColor(for: event.severity)
        material.emission.contents = uiColor(for: event.severity).withAlphaComponent(0.6)
        material.lightingModel = .constant
        sphere.materials = [material]

        self.geometry = sphere

        // Pulse animation for critical
        if event.severity == .critical {
            let scaleUp = SCNAction.scale(to: 1.5, duration: 0.6)
            scaleUp.timingMode = .easeInEaseOut
            let scaleDown = SCNAction.scale(to: 1.0, duration: 0.6)
            scaleDown.timingMode = .easeInEaseOut
            let pulse = SCNAction.repeatForever(.sequence([scaleUp, scaleDown]))
            runAction(pulse, forKey: "pulse")
        }

        // Billboard label
        addLabelNode(text: event.compactLabel, color: uiColor(for: event.severity))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLabelNode(text: String, color: UIColor) {
        let labelSize = CGSize(width: 256, height: 48)
        let scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: labelSize)
        let image = renderer.image { ctx in
            // Background
            let bgRect = CGRect(origin: .zero, size: labelSize)
            UIColor(white: 0.08, alpha: 0.85).setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: 4).fill()

            // Border
            color.withAlphaComponent(0.4).setStroke()
            let borderPath = UIBezierPath(roundedRect: bgRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 4)
            borderPath.lineWidth = 1
            borderPath.stroke()

            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .kern: 1.5,
            ]

            let displayText = String(text.prefix(24))
            let textRect = CGRect(x: 4, y: 10, width: labelSize.width - 8, height: labelSize.height - 12)
            displayText.draw(in: textRect, withAttributes: attributes)
        }

        let plane = SCNPlane(width: 0.12, height: 0.024)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = image
        planeMaterial.emission.contents = image
        planeMaterial.lightingModel = .constant
        planeMaterial.isDoubleSided = true
        planeMaterial.writesToDepthBuffer = false
        plane.materials = [planeMaterial]

        let labelNode = SCNNode(geometry: plane)
        labelNode.position = SCNVector3(0, 0.04, 0)
        labelNode.constraints = [SCNBillboardConstraint()]
        labelNode.name = "label-\(eventID)"

        addChildNode(labelNode)
    }

    private func uiColor(for severity: Severity) -> UIColor {
        switch severity {
        case .critical: UIColor(red: 0.90, green: 0.0, blue: 0.0, alpha: 1.0)
        case .warning: UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
        case .low: UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1.0)
        }
    }
}
