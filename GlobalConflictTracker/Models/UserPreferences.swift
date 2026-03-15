import Foundation

struct UserPreferences: Codable {
    var selectedRegionIDs: [String]
    var notificationsEnabled: Bool
    var criticalAlertsEnabled: Bool

    static let `default` = UserPreferences(
        selectedRegionIDs: [],
        notificationsEnabled: true,
        criticalAlertsEnabled: true
    )
}
