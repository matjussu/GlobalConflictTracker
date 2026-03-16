import SwiftUI
import MapKit

/// Renders a polygon or circular zone on the map with semi-transparent fill and labeled centroid.
/// Used for no-fly zones, blockade areas, and exclusion zones.
struct ZoneOverlay: MapContent {
    let event: ConflictEvent
    let zoneData: ZoneData
    let isSelected: Bool

    var body: some MapContent {
        let color = AppColors.severityColor(event.severity)
        let coordinates = zoneData.boundary.map(\.coordinate)

        if let radius = zoneData.radiusMeters, let center = coordinates.first {
            // Circular zone
            MapCircle(center: center, radius: radius)
                .foregroundStyle(color.opacity(zoneData.fillOpacity))
                .stroke(color.opacity(isSelected ? 0.7 : 0.4), lineWidth: isSelected ? 2.5 : 1.5)
        } else if coordinates.count >= 3 {
            // Polygon zone
            MapPolygon(coordinates: coordinates)
                .foregroundStyle(color.opacity(zoneData.fillOpacity))
                .stroke(color.opacity(isSelected ? 0.7 : 0.4), lineWidth: isSelected ? 2.5 : 1.5)
        }

        // Zone label at centroid
        let centroid = GeoMath.centroid(of: coordinates)
        Annotation(zoneData.zoneLabel, coordinate: centroid, anchor: .center) {
            ZoneLabelView(
                text: zoneData.zoneLabel,
                color: color,
                isActive: zoneData.isActive
            )
        }
    }
}

// MARK: - Zone Label

private struct ZoneLabelView: View {
    let text: String
    let color: Color
    let isActive: Bool

    @State private var blinkOn = true

    var body: some View {
        HStack(spacing: 4) {
            if isActive {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                    .opacity(blinkOn ? 1.0 : 0.3)
            }

            Text(text)
                .font(.system(size: 9, weight: .bold))
                .tracking(2.0)
                .foregroundStyle(color.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColors.surface.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                blinkOn.toggle()
            }
        }
        .allowsHitTesting(false)
    }
}
