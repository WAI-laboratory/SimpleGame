//
//  LevelGenerator.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import Foundation

class LevelGenerator {

    /// Generate a level based on difficulty
    static func generateLevel(_ level: Int) -> SheepGameBoard {
        let board = SheepGameBoard()
        board.level = level

        if level == 1 {
            // Tutorial level - easy and always solvable
            generateTutorialLevel(board)
        } else {
            // Procedural generation with increasing difficulty
            generateProceduralLevel(board, difficulty: level)
        }

        return board
    }

    // MARK: - Tutorial Level (Level 1)

    private static func generateTutorialLevel(_ board: SheepGameBoard) {
        // Simple 3-layer layout with guaranteed solution
        // Use only 3 tile types, 9 of each (27 tiles total)

        let tileTypes: [TileType] = [.sheep, .cow, .pig]
        var tiles: [Tile] = []

        // Layer 0: 3x3 grid (9 tiles)
        for row in 0..<3 {
            for col in 0..<3 {
                let type = tileTypes[(row + col) % 3]
                let tile = Tile(type: type, position: TilePosition(x: col, y: row, layer: 0))
                tiles.append(tile)
            }
        }

        // Layer 1: 2x2 grid offset (4 tiles)
        for row in 0..<2 {
            for col in 0..<2 {
                let type = tileTypes[(row + col + 1) % 3]
                let tile = Tile(type: type, position: TilePosition(x: col + 1, y: row + 1, layer: 1))
                tiles.append(tile)
            }
        }

        // Layer 2: Center 2x2 (4 tiles)
        for row in 0..<2 {
            for col in 0..<2 {
                let type = tileTypes[(row + col + 2) % 3]
                let tile = Tile(type: type, position: TilePosition(x: col + 1, y: row + 1, layer: 2))
                tiles.append(tile)
            }
        }

        // Add remaining tiles to make sets of 3
        // Add 10 more tiles randomly distributed
        for i in 0..<10 {
            let type = tileTypes[i % 3]
            let randomX = Int.random(in: 0..<4)
            let randomY = Int.random(in: 0..<4)
            let layer = (i / 3) + 3
            let tile = Tile(type: type, position: TilePosition(x: randomX, y: randomY, layer: layer))
            tiles.append(tile)
        }

        board.tiles = tiles
    }

    // MARK: - Procedural Level Generation

    private static func generateProceduralLevel(_ board: SheepGameBoard, difficulty: Int) {
        // Determine number of tiles based on difficulty
        // Must be divisible by 3 for match-3 gameplay
        let baseTiles = 30
        let additionalTiles = (difficulty - 2) * 6  // 6 more tiles per level
        let totalTiles = ((baseTiles + additionalTiles) / 3) * 3  // Ensure divisible by 3

        // Determine number of tile types (more types = harder)
        let numTypes = min(4 + (difficulty / 2), TileType.allCases.count)
        let tileTypes = Array(TileType.allCases.shuffled().prefix(numTypes))

        // Generate tiles ensuring each type appears in multiples of 3
        var tiles: [Tile] = []
        let tilesPerType = totalTiles / tileTypes.count

        for tileType in tileTypes {
            // Ensure multiple of 3
            let count = (tilesPerType / 3) * 3
            for _ in 0..<count {
                // Will assign positions later
                let tile = Tile(type: tileType, position: TilePosition(x: 0, y: 0, layer: 0))
                tiles.append(tile)
            }
        }

        // If we need more tiles to reach totalTiles, add them
        while tiles.count < totalTiles {
            let randomType = tileTypes.randomElement()!
            for _ in 0..<min(3, totalTiles - tiles.count) {
                let tile = Tile(type: randomType, position: TilePosition(x: 0, y: 0, layer: 0))
                tiles.append(tile)
            }
        }

        // Shuffle tiles
        tiles.shuffle()

        // Assign positions in a pyramid/layered pattern
        assignTilePositions(&tiles, difficulty: difficulty)

        board.tiles = tiles
    }

    // MARK: - Position Assignment

    private static func assignTilePositions(_ tiles: inout [Tile], difficulty: Int) {
        // Create a pyramid structure with multiple layers
        let gridSize = 6 + (difficulty / 3)  // Larger grid for higher difficulties
        let maxLayers = 3 + (difficulty / 2)  // More layers for higher difficulties

        var positionIndex = 0

        // Layer 0: Base layer - wide spread
        let baseSize = gridSize
        for row in 0..<baseSize {
            for col in 0..<baseSize where positionIndex < tiles.count {
                // Random sparse placement
                if Int.random(in: 0...100) < 60 {  // 60% chance to place
                    tiles[positionIndex].position = TilePosition(x: col, y: row, layer: 0)
                    positionIndex += 1
                }
            }
        }

        // Middle layers: Progressively smaller
        for layer in 1..<maxLayers {
            let layerSize = max(2, baseSize - layer * 2)
            let offset = layer

            for row in 0..<layerSize where positionIndex < tiles.count {
                for col in 0..<layerSize where positionIndex < tiles.count {
                    // Higher chance of placement in middle layers
                    if Int.random(in: 0...100) < 70 {
                        tiles[positionIndex].position = TilePosition(x: col + offset, y: row + offset, layer: layer)
                        positionIndex += 1
                    }
                }
            }
        }

        // Top layers: Concentrated center
        while positionIndex < tiles.count {
            let layer = maxLayers + (positionIndex - positionIndex % 3) / 6
            let centerOffset = gridSize / 2
            let randomOffset = Int.random(in: -2...2)

            tiles[positionIndex].position = TilePosition(
                x: centerOffset + randomOffset,
                y: centerOffset + randomOffset,
                layer: layer
            )
            positionIndex += 1
        }
    }

    // MARK: - Level Templates

    /// Generate a specific level pattern (alternative to procedural)
    static func generateTemplateLevel(_ template: LevelTemplate) -> SheepGameBoard {
        let board = SheepGameBoard()
        board.level = template.level

        // Create tiles based on template
        var tiles: [Tile] = []

        for tileData in template.tileData {
            let tile = Tile(
                type: tileData.type,
                position: TilePosition(x: tileData.x, y: tileData.y, layer: tileData.layer)
            )
            tiles.append(tile)
        }

        board.tiles = tiles
        return board
    }
}

// MARK: - Level Template Structure

struct LevelTemplate {
    let level: Int
    let tileData: [TileData]

    struct TileData {
        let type: TileType
        let x: Int
        let y: Int
        let layer: Int
    }
}
