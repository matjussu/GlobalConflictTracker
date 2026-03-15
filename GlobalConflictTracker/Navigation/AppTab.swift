import SwiftUI

enum AppTab: String, CaseIterable, Hashable {
    case map
    case intel
    case factions
    case system

    var title: String {
        switch self {
        case .map: "MAP"
        case .intel: "INTEL"
        case .factions: "FACTIONS"
        case .system: "SYSTEM"
        }
    }

    var icon: String {
        switch self {
        case .map: "map.fill"
        case .intel: "doc.text.fill"
        case .factions: "person.3.fill"
        case .system: "gearshape.fill"
        }
    }

    var label: Label<Text, Image> {
        Label(title, systemImage: icon)
    }
}
