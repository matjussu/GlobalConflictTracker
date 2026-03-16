import SwiftUI

enum EventSubtype: String, Codable, CaseIterable {
    case missileStrike
    case airstrike
    case droneStrike
    case airspaceViolation

    case navalBlockade
    case fleetMovement
    case navalEngagement

    case troopMovement
    case artilleryBarrage

    case cyberAttack
    case cyberEspionage

    case summit
    case sanctions
    case treatyEvent

    var icon: String {
        switch self {
        case .missileStrike: "flame.fill"
        case .airstrike: "airplane"
        case .droneStrike: "paperplane.fill"
        case .airspaceViolation: "exclamationmark.triangle.fill"
        case .navalBlockade: "xmark.octagon.fill"
        case .fleetMovement: "ferry.fill"
        case .navalEngagement: "water.waves"
        case .troopMovement: "figure.walk"
        case .artilleryBarrage: "burst.fill"
        case .cyberAttack: "lock.shield.fill"
        case .cyberEspionage: "eye.fill"
        case .summit: "building.columns.fill"
        case .sanctions: "hand.raised.fill"
        case .treatyEvent: "doc.text.fill"
        }
    }

    var label: String {
        switch self {
        case .missileStrike: "MISSILE STRIKE"
        case .airstrike: "AIRSTRIKE"
        case .droneStrike: "DRONE STRIKE"
        case .airspaceViolation: "AIRSPACE VIOLATION"
        case .navalBlockade: "NAVAL BLOCKADE"
        case .fleetMovement: "FLEET MOVEMENT"
        case .navalEngagement: "NAVAL ENGAGEMENT"
        case .troopMovement: "TROOP MOVEMENT"
        case .artilleryBarrage: "ARTILLERY BARRAGE"
        case .cyberAttack: "CYBER ATTACK"
        case .cyberEspionage: "CYBER ESPIONAGE"
        case .summit: "SUMMIT"
        case .sanctions: "SANCTIONS"
        case .treatyEvent: "TREATY"
        }
    }
}
