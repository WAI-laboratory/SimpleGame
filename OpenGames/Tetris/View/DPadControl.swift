//
//  DPadControl.swift
//  OpenGames
//
//  D-pad control for Tetris game
//

import UIKit
import SnapKit

class DPadControl: UIView {

    // Button actions
    var onLeftPressed: (() -> Void)?
    var onRightPressed: (() -> Void)?
    var onDownPressed: (() -> Void)?
    var onUpPressed: (() -> Void)?

    private let leftButton = GameButton(title: "◀", frame: .zero)
    private let rightButton = GameButton(title: "▶", frame: .zero)
    private let downButton = GameButton(title: "▼", frame: .zero)
    private let upButton = GameButton(title: "▲", frame: .zero)
    private let centerView = UIView()

    private var buttonSize: CGFloat = 50
    private var spacing: CGFloat = 4

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

        // Center view for spacing
        centerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        centerView.layer.cornerRadius = 5

        // Configure buttons
        configureButton(leftButton, title: "◀")
        configureButton(rightButton, title: "▶")
        configureButton(downButton, title: "▼")
        configureButton(upButton, title: "▲")

        // Add actions
        leftButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(downTapped), for: .touchUpInside)
        upButton.addTarget(self, action: #selector(upTapped), for: .touchUpInside)

        // Add continuous press for down button
        downButton.addTarget(self, action: #selector(downTouchDown), for: .touchDown)
        downButton.addTarget(self, action: #selector(downTouchUp), for: [.touchUpInside, .touchUpOutside])

        // Layout
        addSubview(centerView)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(downButton)
        addSubview(upButton)

        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(buttonSize)
        }

        leftButton.snp.makeConstraints { make in
            make.trailing.equalTo(centerView.snp.leading).offset(-spacing)
            make.centerY.equalTo(centerView)
            make.width.height.equalTo(buttonSize)
        }

        rightButton.snp.makeConstraints { make in
            make.leading.equalTo(centerView.snp.trailing).offset(spacing)
            make.centerY.equalTo(centerView)
            make.width.height.equalTo(buttonSize)
        }

        upButton.snp.makeConstraints { make in
            make.bottom.equalTo(centerView.snp.top).offset(-spacing)
            make.centerX.equalTo(centerView)
            make.width.height.equalTo(buttonSize)
        }

        downButton.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(spacing)
            make.centerX.equalTo(centerView)
            make.width.height.equalTo(buttonSize)
        }
    }

    private func configureButton(_ button: GameButton, title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }

    // MARK: - Button Actions
    @objc private func leftTapped() {
        onLeftPressed?()
        animateButton(leftButton)
    }

    @objc private func rightTapped() {
        onRightPressed?()
        animateButton(rightButton)
    }

    @objc private func upTapped() {
        onUpPressed?()
        animateButton(upButton)
    }

    @objc private func downTapped() {
        onDownPressed?()
        animateButton(downButton)
    }

    private var downTimer: Timer?

    @objc private func downTouchDown() {
        onDownPressed?()
        // Start repeating down movement
        downTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.onDownPressed?()
        }
    }

    @objc private func downTouchUp() {
        downTimer?.invalidate()
        downTimer = nil
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
        let totalSize = buttonSize * 3 + spacing * 4
        return CGSize(width: totalSize, height: totalSize)
    }
}
