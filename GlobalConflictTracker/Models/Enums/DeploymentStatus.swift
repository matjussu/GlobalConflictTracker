import Foundation

enum DeploymentStatus: String, Codable, CaseIterable {
    case activeDeployment
    case standby
    case borderOps
    case maritimePatrol
    case logisticsSupport
    case domesticSecurity

    var label: String {
        switch self {
        case .activeDeployment: "Active Deployment"
        case .standby: "Standby"
        case .borderOps: "Border Ops"
        case .maritimePatrol: "Maritime Patrol"
        case .logisticsSupport: "Logistics Support"
        case .domesticSecurity: "Domestic Security"
        }
    }

    /// Whether this status indicates active operations
    var isActive: Bool {
        switch self {
        case .activeDeployment, .borderOps: true
        default: false
        }
    }
}
