import Foundation

enum FactionType: String, Codable, CaseIterable {
    case nation
    case alliance
    case nonState

    var label: String {
        switch self {
        case .nation: "Nation State"
        case .alliance: "Alliance"
        case .nonState: "Non-State Actor"
        }
    }

    var icon: String {
        switch self {
        case .nation: "shield.checkered"
        case .alliance: "star.circle"
        case .nonState: "flag.2.crossed"
        }
    }
}
