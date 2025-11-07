//
//  Tile.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import Foundation
import UIKit

/// Represents different types of tiles in the game
enum TileType: Int, Codable, CaseIterable {
    case sheep = 0
    case cow = 1
    case pig = 2
    case chicken = 3
    case dog = 4
    case cat = 5
    case rabbit = 6
    case duck = 7
    case horse = 8
    case panda = 9

    /// Get the emoji representation for each tile type
    var emoji: String {
        switch self {
        case .sheep: return "🐑"
        case .cow: return "🐄"
        case .pig: return "🐷"
        case .chicken: return "🐔"
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .rabbit: return "🐰"
        case .duck: return "🦆"
        case .horse: return "🐴"
        case .panda: return "🐼"
        }
    }

    /// Get the color for each tile type
    var color: UIColor {
        switch self {
        case .sheep: return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        case .cow: return UIColor(red: 0.85, green: 0.7, blue: 0.6, alpha: 1.0)
        case .pig: return UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0)
        case .chicken: return UIColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0)
        case .dog: return UIColor(red: 0.85, green: 0.65, blue: 0.4, alpha: 1.0)
        case .cat: return UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)
        case .rabbit: return UIColor(red: 0.95, green: 0.85, blue: 0.95, alpha: 1.0)
        case .duck: return UIColor(red: 1.0, green: 0.95, blue: 0.4, alpha: 1.0)
        case .horse: return UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        case .panda: return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }
}

/// Represents a single tile in the game
class Tile: Codable {
    let id: UUID
    let type: TileType
    var position: TilePosition
    var isSelected: Bool = false
    var isInCollection: Bool = false

    init(type: TileType, position: TilePosition) {
        self.id = UUID()
        self.type = type
        self.position = position
    }

    /// Check if this tile matches another tile
    func matches(_ other: Tile) -> Bool {
        return self.type == other.type
    }
}

/// Represents the position of a tile in 3D space
struct TilePosition: Codable, Equatable {
    var x: Int  // Horizontal position (column)
    var y: Int  // Vertical position (row)
    var layer: Int  // Layer (0 = bottom, higher = on top)

    /// Check if this position overlaps with another position
    func overlaps(with other: TilePosition) -> Bool {
        return self.x == other.x && self.y == other.y
    }

    /// Check if this tile is directly above another tile
    func isAbove(_ other: TilePosition) -> Bool {
        return self.layer > other.layer && overlaps(with: other)
    }
}

/// Extension for equatable comparison
extension Tile: Equatable {
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Tile: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
