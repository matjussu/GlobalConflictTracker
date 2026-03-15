import Foundation

struct Faction: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var emblemURL: String
    var type: FactionType
    var personnelCount: Int
    var fleetStrength: Int
    var airAssets: Int
    var status: DeploymentStatus
    var deploymentZones: [String]
    var recentEventIDs: [String]
    var personnelTrend: Double
    var fleetTrend: Double
    var airTrend: Double

    /// Compact formatted personnel count (e.g. "1.2M", "480K")
    var formattedPersonnel: String {
        Self.compactNumber(personnelCount)
    }

    var formattedFleet: String {
        Self.compactNumber(fleetStrength)
    }

    var formattedAir: String {
        Self.compactNumber(airAssets)
    }

    static func compactNumber(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            return "\(value / 1_000)K"
        }
        return "\(value)"
    }
}
