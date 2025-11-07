//
//  HoldPiece.swift
//  OpenGames
//
//  Display component for held piece in Tetris
//

import UIKit

class HoldPiece: UIView {

    var heldBrick: Brick? {
        didSet {
            setNeedsDisplay()
        }
    }

    private let titleLabel = UILabel()
    private let brickDisplaySize: CGFloat = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1.0)
        layer.cornerRadius = 8
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1

        titleLabel.text = "HOLD"
        titleLabel.textColor = .white
        titleLabel.font = Swiftris.GameFont(14)
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 0, y: 8, width: bounds.width, height: 20)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 8, width: bounds.width, height: 20)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let brick = heldBrick else { return }

        let brickSize = GameBoard.smallBrickSize
        let displayRect = CGRect(x: 0, y: 30, width: bounds.width, height: bounds.height - 30)

        // Calculate brick bounds
        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        var maxY = -CGFloat.infinity

        for point in brick.points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        let brickWidth = (maxX - minX + 1) * CGFloat(brickSize)
        let brickHeight = (maxY - minY + 1) * CGFloat(brickSize)

        // Center the brick in display area
        let offsetX = (displayRect.width - brickWidth) / 2 + displayRect.minX
        let offsetY = (displayRect.height - brickHeight) / 2 + displayRect.minY

        // Draw brick
        for point in brick.points {
            let x = offsetX + (point.x - minX) * CGFloat(brickSize)
            let y = offsetY + (point.y - minY) * CGFloat(brickSize)

            let block = CGRect(x: x, y: y, width: CGFloat(brickSize), height: CGFloat(brickSize))
            brick.color.set()
            UIBezierPath(roundedRect: block, cornerRadius: 2).fill()
        }
    }

    func clear() {
        heldBrick = nil
        setNeedsDisplay()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: brickDisplaySize, height: brickDisplaySize)
    }
}
