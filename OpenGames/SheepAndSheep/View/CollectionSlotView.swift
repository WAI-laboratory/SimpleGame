//
//  CollectionSlotView.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import UIKit
import SnapKit

class CollectionSlotView: UIView {
    private let maxSlots = 7
    private var slotViews: [UIView] = []
    private var tileViews: [TileView] = []

    var tiles: [Tile] = [] {
        didSet {
            updateDisplay()
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
        backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor

        // Create slot placeholders
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        for _ in 0..<maxSlots {
            let slotView = UIView()
            slotView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
            slotView.layer.cornerRadius = 6
            slotView.layer.borderWidth = 1
            slotView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor

            slotView.snp.makeConstraints { make in
                make.width.height.equalTo(55)
            }

            stackView.addArrangedSubview(slotView)
            slotViews.append(slotView)
        }
    }

    private func updateDisplay() {
        // Remove existing tile views
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()

        // Add tile views for current tiles
        for (index, tile) in tiles.enumerated() where index < maxSlots {
            let tileView = TileView(tile: tile)
            slotViews[index].addSubview(tileView)

            tileView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(50)
            }

            tileViews.append(tileView)
        }

        // Highlight slots based on fill level
        for (index, slotView) in slotViews.enumerated() {
            if index < tiles.count {
                slotView.layer.borderColor = UIColor.systemBlue.cgColor
                slotView.layer.borderWidth = 2
            } else {
                slotView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
                slotView.layer.borderWidth = 1
            }
        }

        // Warning color if almost full
        if tiles.count >= maxSlots - 1 {
            layer.borderColor = UIColor.systemRed.cgColor
            backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.2, alpha: 1.0)
        } else {
            layer.borderColor = UIColor.white.cgColor
            backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
        }
    }

    func animateMatchRemoval(at indices: [Int], completion: @escaping () -> Void) {
        var animationsCompleted = 0
        let totalAnimations = indices.count

        for index in indices where index < tileViews.count {
            let tileView = tileViews[index]
            tileView.animateRemoval {
                animationsCompleted += 1
                if animationsCompleted == totalAnimations {
                    completion()
                }
            }
        }

        if totalAnimations == 0 {
            completion()
        }
    }

    func getPositionForSlot(_ index: Int) -> CGPoint {
        guard index < slotViews.count else { return .zero }
        let slotView = slotViews[index]
        return convert(slotView.center, to: superview)
    }
}
