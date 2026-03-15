import SwiftUI

enum EventType: String, Codable, CaseIterable {
    case naval
    case cyber
    case diplomatic
    case airspace

    var icon: String {
        switch self {
        case .naval: "water.waves"
        case .cyber: "lock.shield"
        case .diplomatic: "building.columns"
        case .airspace: "airplane"
        }
    }

    var color: Color {
        switch self {
        case .naval: Color(red: 0.2, green: 0.6, blue: 1.0)
        case .cyber: Color(red: 0.6, green: 0.2, blue: 1.0)
        case .diplomatic: Color(red: 1.0, green: 0.8, blue: 0.2)
        case .airspace: Color(red: 1.0, green: 0.4, blue: 0.2)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .naval: "Naval event"
        case .cyber: "Cyber event"
        case .diplomatic: "Diplomatic event"
        case .airspace: "Airspace event"
        }
    }
}
