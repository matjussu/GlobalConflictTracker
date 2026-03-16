import Foundation

enum MapVisualization: Codable, Hashable {
    case point
    case trajectory(TrajectoryData)
    case movementPath(MovementPathData)
    case zone(ZoneData)
    case connection(ConnectionData)

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    private enum VisualizationType: String, Codable {
        case point, trajectory, movementPath, zone, connection
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VisualizationType.self, forKey: .type)
        switch type {
        case .point:
            self = .point
        case .trajectory:
            let data = try container.decode(TrajectoryData.self, forKey: .data)
            self = .trajectory(data)
        case .movementPath:
            let data = try container.decode(MovementPathData.self, forKey: .data)
            self = .movementPath(data)
        case .zone:
            let data = try container.decode(ZoneData.self, forKey: .data)
            self = .zone(data)
        case .connection:
            let data = try container.decode(ConnectionData.self, forKey: .data)
            self = .connection(data)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .point:
            try container.encode(VisualizationType.point, forKey: .type)
        case .trajectory(let data):
            try container.encode(VisualizationType.trajectory, forKey: .type)
            try container.encode(data, forKey: .data)
        case .movementPath(let data):
            try container.encode(VisualizationType.movementPath, forKey: .type)
            try container.encode(data, forKey: .data)
        case .zone(let data):
            try container.encode(VisualizationType.zone, forKey: .type)
            try container.encode(data, forKey: .data)
        case .connection(let data):
            try container.encode(VisualizationType.connection, forKey: .type)
            try container.encode(data, forKey: .data)
        }
    }
}
