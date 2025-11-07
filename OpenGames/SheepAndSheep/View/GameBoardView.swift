//
//  GameBoardView.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import UIKit

protocol GameBoardViewDelegate: AnyObject {
    func didSelectTile(_ tile: Tile)
}

class GameBoardView: UIView {
    weak var delegate: GameBoardViewDelegate?
    private var tileViews: [UUID: TileView] = [:]
    private let tileSize: CGFloat = 60

    var gameBoard: SheepGameBoard? {
        didSet {
            refreshDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.9, green: 0.85, blue: 0.75, alpha: 1.0)
        layer.cornerRadius = 12
    }

    func refreshDisplay() {
        // Remove all existing tile views
        tileViews.values.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()

        guard let gameBoard = gameBoard else { return }

        // Sort tiles by layer (bottom to top) for proper rendering
        let sortedTiles = gameBoard.tiles.sorted { $0.position.layer < $1.position.layer }

        // Create and position tile views
        for tile in sortedTiles where !tile.isInCollection {
            let tileView = TileView(tile: tile)
            tileView.frame = frameForTile(tile)

            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTileTap(_:)))
            tileView.addGestureRecognizer(tapGesture)
            tileView.isUserInteractionEnabled = true

            addSubview(tileView)
            tileViews[tile.id] = tileView

            // Disable interaction if not accessible
            if !gameBoard.isTileAccessible(tile) {
                tileView.alpha = 0.5
                tileView.isUserInteractionEnabled = false
            }
        }
    }

    private func frameForTile(_ tile: Tile) -> CGRect {
        // Calculate position based on grid coordinates and layer
        let baseX: CGFloat = 20
        let baseY: CGFloat = 20
        let spacing: CGFloat = 8

        let x = baseX + CGFloat(tile.position.x) * (tileSize + spacing) + CGFloat(tile.position.layer) * 3
        let y = baseY + CGFloat(tile.position.y) * (tileSize + spacing) + CGFloat(tile.position.layer) * 3

        return CGRect(x: x, y: y, width: tileSize, height: tileSize)
    }

    @objc private func handleTileTap(_ gesture: UITapGestureRecognizer) {
        guard let tileView = gesture.view as? TileView else { return }
        guard let gameBoard = gameBoard else { return }

        // Check if tile is accessible
        if gameBoard.isTileAccessible(tileView.tile) {
            tileView.animateSelection()
            delegate?.didSelectTile(tileView.tile)
        }
    }

    func animateTileToCollection(_ tile: Tile, toPosition: CGPoint, completion: @escaping () -> Void) {
        guard let tileView = tileViews[tile.id] else {
            completion()
            return
        }

        // Animate tile moving to collection
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut], animations: {
            tileView.center = toPosition
            tileView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            tileView.removeFromSuperview()
            self.tileViews.removeValue(forKey: tile.id)
            completion()
        }
    }

    func highlightAccessibleTiles() {
        guard let gameBoard = gameBoard else { return }
        let accessibleTiles = gameBoard.getAccessibleTiles()

        for (_, tileView) in tileViews {
            if accessibleTiles.contains(where: { $0.id == tileView.tile.id }) {
                tileView.alpha = 1.0
                tileView.isUserInteractionEnabled = true
            } else {
                tileView.alpha = 0.5
                tileView.isUserInteractionEnabled = false
            }
        }
    }
}
