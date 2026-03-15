import SwiftUI
import MapKit

/// Cluster annotation for dense event areas on the map
struct ConflictCluster: View {
    let events: [ConflictEvent]

    private var maxSeverity: Severity {
        if events.contains(where: { $0.severity == .critical }) { return .critical }
        if events.contains(where: { $0.severity == .warning }) { return .warning }
        return .low
    }

    var body: some View {
        ClusterMarkerView(count: events.count, maxSeverity: maxSeverity)
    }
}

#Preview {
    ConflictCluster(events: Array(SampleData.events.prefix(3)))
        .padding()
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
