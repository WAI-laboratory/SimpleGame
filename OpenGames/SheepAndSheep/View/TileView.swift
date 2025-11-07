//
//  TileView.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import UIKit

class TileView: UIView {
    var tile: Tile
    private let emojiLabel = UILabel()

    init(tile: Tile) {
        self.tile = tile
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Background color based on tile type
        backgroundColor = tile.type.color
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor

        // Shadow for 3D effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3

        // Emoji label
        emojiLabel.text = tile.type.emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        addSubview(emojiLabel)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // Update appearance
        updateAppearance()
    }

    func updateAppearance() {
        // Highlight if selected
        if tile.isSelected {
            layer.borderColor = UIColor.systemBlue.cgColor
            layer.borderWidth = 3
            transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } else {
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 2
            transform = .identity
        }

        // Adjust alpha based on layer (depth effect)
        alpha = 1.0 - (CGFloat(tile.position.layer) * 0.05)
    }

    func animateSelection() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }

    func animateRemoval(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.alpha = 0
        }) { _ in
            completion()
        }
    }
}
