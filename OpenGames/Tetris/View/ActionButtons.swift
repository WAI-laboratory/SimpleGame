//
//  ActionButtons.swift
//  OpenGames
//
//  Action buttons for Tetris game (Rotate, Hard Drop, Hold)
//

import UIKit
import SnapKit

class ActionButtons: UIView {

    // Button actions
    var onRotatePressed: (() -> Void)?
    var onHardDropPressed: (() -> Void)?
    var onHoldPressed: (() -> Void)?

    let rotateButton = GameButton(title: "↻", frame: .zero)
    let hardDropButton = GameButton(title: "⬇", frame: .zero)
    let holdButton = GameButton(title: "HOLD", frame: .zero)

    private let buttonSize: CGFloat = 60
    private let spacing: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        // Configure buttons
        configureButton(rotateButton, title: "↻", fontSize: 28)
        configureButton(hardDropButton, title: "⬇", fontSize: 28)
        configureButton(holdButton, title: "HOLD", fontSize: 14)

        // Add labels below buttons
        let rotateLabel = createLabel(text: "Rotate")
        let dropLabel = createLabel(text: "Drop")
        let holdLabel = createLabel(text: "Hold")

        // Add actions
        rotateButton.addTarget(self, action: #selector(rotateTapped), for: .touchUpInside)
        hardDropButton.addTarget(self, action: #selector(hardDropTapped), for: .touchUpInside)
        holdButton.addTarget(self, action: #selector(holdTapped), for: .touchUpInside)

        // Layout - vertical stack
        let rotateStack = createButtonStack(button: rotateButton, label: rotateLabel)
        let dropStack = createButtonStack(button: hardDropButton, label: dropLabel)
        let holdStack = createButtonStack(button: holdButton, label: holdLabel)

        let mainStack = UIStackView(arrangedSubviews: [rotateStack, dropStack, holdStack])
        mainStack.axis = .vertical
        mainStack.spacing = spacing
        mainStack.alignment = .fill
        mainStack.distribution = .fillEqually

        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createButtonStack(button: UIButton, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center

        button.snp.makeConstraints { make in
            make.width.height.equalTo(buttonSize)
        }

        return stack
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        return label
    }

    private func configureButton(_ button: GameButton, title: String, fontSize: CGFloat) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }

    // MARK: - Button Actions
    @objc private func rotateTapped() {
        onRotatePressed?()
        animateButton(rotateButton)
    }

    @objc private func hardDropTapped() {
        onHardDropPressed?()
        animateButton(hardDropButton)
    }

    @objc private func holdTapped() {
        onHoldPressed?()
        animateButton(holdButton)
    }

    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let totalHeight = buttonSize * 3 + spacing * 2 + 30 // buttons + spacing + labels
        return CGSize(width: buttonSize, height: totalHeight)
    }
}
