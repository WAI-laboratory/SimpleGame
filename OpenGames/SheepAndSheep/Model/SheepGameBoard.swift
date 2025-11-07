//
//  GameBoard.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import Foundation

/// Game state enumeration
enum SheepGameState: Codable {
    case playing
    case won
    case lost
}

/// Manages the game board, tiles, and game logic
class SheepGameBoard: Codable {
    var tiles: [Tile] = []
    var collectionSlots: [Tile] = []  // Max 7 tiles
    var state: SheepGameState = .playing
    var score: Int = 0
    var level: Int = 1
    var movesHistory: [[Tile]] = []  // For undo functionality

    let maxCollectionSlots = 7

    init() {
        // Empty init - will be populated by level generator
    }

    // MARK: - Tile Accessibility

    /// Check if a tile can be selected (not blocked by tiles above it)
    func isTileAccessible(_ tile: Tile) -> Bool {
        // A tile is accessible if no other tile is directly above it
        for otherTile in tiles {
            if otherTile.id != tile.id &&
               otherTile.position.isAbove(tile.position) {
                return false
            }
        }
        return true
    }

    /// Get all accessible tiles
    func getAccessibleTiles() -> [Tile] {
        return tiles.filter { isTileAccessible($0) && !$0.isInCollection }
    }

    // MARK: - Game Actions

    /// Select a tile and move it to collection
    func selectTile(_ tile: Tile) -> Bool {
        guard isTileAccessible(tile) else { return false }
        guard collectionSlots.count < maxCollectionSlots else { return false }
        guard state == .playing else { return false }

        // Save state for undo
        saveStateForUndo()

        // Remove from board
        if let index = tiles.firstIndex(of: tile) {
            tiles[index].isInCollection = true
            tiles[index].isSelected = false
        }

        // Add to collection
        collectionSlots.append(tile)

        // Check for matches
        checkAndRemoveMatches()

        // Check game state
        checkGameState()

        return true
    }

    // MARK: - Match Detection

    /// Check for 3 matching tiles in collection and remove them
    private func checkAndRemoveMatches() {
        // Count tiles by type
        var typeCounts: [TileType: [Tile]] = [:]
        for tile in collectionSlots {
            if typeCounts[tile.type] == nil {
                typeCounts[tile.type] = []
            }
            typeCounts[tile.type]?.append(tile)
        }

        // Find types with 3 or more matches
        for (type, matchingTiles) in typeCounts {
            if matchingTiles.count >= 3 {
                // Remove 3 matching tiles
                let tilesToRemove = Array(matchingTiles.prefix(3))
                for tile in tilesToRemove {
                    if let index = collectionSlots.firstIndex(of: tile) {
                        collectionSlots.remove(at: index)
                    }
                    // Remove from tiles array completely
                    if let tileIndex = tiles.firstIndex(of: tile) {
                        tiles.remove(at: tileIndex)
                    }
                }

                // Increase score
                score += 30

                // Check for more matches recursively
                checkAndRemoveMatches()
                break // Only process one match at a time to maintain proper order
            }
        }
    }

    // MARK: - Game State

    /// Check if game is won or lost
    private func checkGameState() {
        // Check for win
        if tiles.filter({ !$0.isInCollection }).isEmpty {
            state = .won
            return
        }

        // Check for loss (7 slots filled without match)
        if collectionSlots.count >= maxCollectionSlots {
            state = .lost
            return
        }

        state = .playing
    }

    /// Check if there are any valid moves left
    func hasValidMoves() -> Bool {
        let accessible = getAccessibleTiles()
        if accessible.isEmpty {
            return false
        }

        // Check if adding any accessible tile would cause immediate loss
        if collectionSlots.count >= maxCollectionSlots {
            return false
        }

        return true
    }

    // MARK: - Undo System

    private func saveStateForUndo() {
        movesHistory.append(collectionSlots)
    }

    func canUndo() -> Bool {
        return !movesHistory.isEmpty
    }

    func undo() -> Bool {
        guard canUndo() else { return false }
        guard let previousState = movesHistory.popLast() else { return false }

        // Restore collection slots
        let tilesToRestore = collectionSlots.filter { !previousState.contains($0) }
        collectionSlots = previousState

        // Move tiles back to board
        for tile in tilesToRestore {
            if let index = tiles.firstIndex(of: tile) {
                tiles[index].isInCollection = false
            }
        }

        // Reset game state if was lost
        if state == .lost {
            state = .playing
        }

        return true
    }

    // MARK: - Power-Ups

    /// Shuffle accessible tiles (randomize their positions)
    func shuffle() {
        var accessibleTiles = getAccessibleTiles()
        guard !accessibleTiles.isEmpty else { return }

        // Get all positions of accessible tiles
        var positions = accessibleTiles.map { $0.position }
        positions.shuffle()

        // Reassign positions
        for (index, tile) in accessibleTiles.enumerated() {
            if let tileIndex = tiles.firstIndex(of: tile) {
                tiles[tileIndex].position = positions[index]
            }
        }
    }

    /// Remove 3 tiles from collection temporarily (power-up)
    func removeTilesFromCollection() -> [Tile] {
        let count = min(3, collectionSlots.count)
        var removed: [Tile] = []

        for _ in 0..<count {
            if let tile = collectionSlots.popLast() {
                removed.append(tile)
                // Mark as not in collection but don't add back to board
                if let index = tiles.firstIndex(of: tile) {
                    tiles[index].isInCollection = false
                }
            }
        }

        // Reset state if was lost
        if state == .lost && collectionSlots.count < maxCollectionSlots {
            state = .playing
        }

        return removed
    }

    /// Restore removed tiles back to board
    func restoreTilesToBoard(_ tilesToRestore: [Tile]) {
        for tile in tilesToRestore {
            if let index = tiles.firstIndex(of: tile) {
                tiles[index].isInCollection = false
            }
        }
    }

    // MARK: - Reset

    func reset() {
        collectionSlots.removeAll()
        movesHistory.removeAll()
        state = .playing
        score = 0

        // Reset all tiles
        for i in 0..<tiles.count {
            tiles[i].isInCollection = false
            tiles[i].isSelected = false
        }
    }
}
