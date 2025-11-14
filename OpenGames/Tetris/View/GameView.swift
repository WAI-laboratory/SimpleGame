//
//  GameView.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//

import UIKit
import SnapKit
import AddThen

protocol GameViewDelegate: AnyObject {
    func didSelectPlay()
    func didSelectPause()
    func didSelectStop()
}

class GameView: UIView {

    var gameScore = GameScore(frame:CGRect.zero)
    var gameBoard = GameBoard(frame:CGRect.zero)
    var nextBrick = NextBrick(frame:CGRect.zero)
    var holdPiece = HoldPiece(frame:CGRect.zero)

    // Movement buttons
    let leftButton = GameButton(title: "◀", frame: .zero)
    let rightButton = GameButton(title: "▶", frame: .zero)
    let downButton = GameButton(title: "▼", frame: .zero)

    // Action buttons
    let rotateLeftButton = GameButton(title: "↶", frame: .zero)
    let rotateRightButton = GameButton(title: "↷", frame: .zero)
    let hardDropButton = GameButton(title: "⬇", frame: .zero)
    let holdButton = GameButton(title: "Hold", frame: .zero)
    
    weak var delegate: GameViewDelegate?

    init(_ superView:UIView) {
        super.init(frame: superView.bounds)
        superView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)
        superView.addSubview(self)

        self.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)

        setupUI()
        setupBurgerMenu()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit GameView")
    }

    private func setupUI() {
        // Add main game components
        addSubview(gameScore)
        addSubview(holdPiece)
        addSubview(gameBoard)
        addSubview(nextBrick)

        // Setup constraints
        gameScore.translatesAutoresizingMaskIntoConstraints = false
        gameScore.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        holdPiece.translatesAutoresizingMaskIntoConstraints = false
        holdPiece.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.top.equalTo(nextBrick.snp.bottom).offset(20)
            make.width.height.equalTo(90)
        }

        gameBoard.translatesAutoresizingMaskIntoConstraints = false
        gameBoard.snp.makeConstraints { make in
            make.top.equalTo(self.gameScore.snp.bottom)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(GameBoard.width)
            make.height.equalTo(GameBoard.height)
        }

        nextBrick.translatesAutoresizingMaskIntoConstraints = false
        nextBrick.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(gameScore.snp.bottom).offset(20)
            make.width.equalTo(90)
            make.height.equalTo(120)
        }

        // Setup movement buttons at bottom
        setupMovementButtons()

        // Setup action buttons on right side
        setupActionButtons()
    }

    private func setupBurgerMenu() {
        // Create menu actions
        let playAction = UIAction(title: "▶ Play", image: nil) { [weak self] _ in
            self?.delegate?.didSelectPlay()
        }

        let pauseAction = UIAction(title: "⏸ Pause", image: nil) { [weak self] _ in
            self?.delegate?.didSelectPause()
        }

        let stopAction = UIAction(title: "⏹ Stop", image: nil) { [weak self] _ in
            self?.delegate?.didSelectStop()
        }

        // Create menu
        let menu = UIMenu(title: "Game Controls", children: [playAction, pauseAction, stopAction])

        // Assign menu to burger button
        gameScore.burgerMenuButton.menu = menu
        gameScore.burgerMenuButton.showsMenuAsPrimaryAction = true
    }

    // Menu action handlers - these can be overridden by the view controller
    func handlePlayAction() {
        // Default implementation - subclasses can override
        NotificationCenter.default.post(name: Notification.Name("PlayGameNotification"), object: nil)
    }

    func handlePauseAction() {
        // Default implementation - subclasses can override
        NotificationCenter.default.post(name: Notification.Name("PauseGameNotification"), object: nil)
    }

    func handleStopAction() {
        // Default implementation - subclasses can override
        NotificationCenter.default.post(name: Notification.Name("StopGameNotification"), object: nil)
    }


    private func setupMovementButtons() {
        // Create container for movement buttons
        let movementContainer = UIView()
        movementContainer.backgroundColor = .clear
        addSubview(movementContainer)

        movementContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }

        // Configure buttons
        configureButton(leftButton, title: "◀", fontSize: 24)
        configureButton(rightButton, title: "▶", fontSize: 24)
        configureButton(downButton, title: "▼", fontSize: 24)

        movementContainer.addSubview(leftButton)
        movementContainer.addSubview(rightButton)
//        movementContainer.addSubview(downButton)

        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        rightButton.snp.makeConstraints { make in
            make.leading.equalTo(leftButton.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

    }

    private func setupActionButtons() {
        // Create container for action buttons
        let actionContainer = UIView()
        actionContainer.backgroundColor = .clear
        addSubview(actionContainer)

        actionContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(60)
            make.height.equalTo(280)
        }

        // Configure buttons
        configureButton(holdButton, title: "Hold", fontSize: 12)
        configureButton(hardDropButton, title: "⬇", fontSize: 28)
        configureButton(rotateRightButton, title: "↷", fontSize: 28)
        configureButton(rotateLeftButton, title: "↶", fontSize: 28)

        actionContainer.addSubview(holdButton)
        actionContainer.addSubview(hardDropButton)
        actionContainer.addSubview(rotateRightButton)
        actionContainer.addSubview(rotateLeftButton)

        holdButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        hardDropButton.snp.makeConstraints { make in
            make.top.equalTo(holdButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        rotateRightButton.snp.makeConstraints { make in
            make.top.equalTo(hardDropButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        rotateLeftButton.snp.makeConstraints { make in
            make.top.equalTo(rotateRightButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }

    private func configureButton(_ button: GameButton, title: String, fontSize: CGFloat = 16, bgColor: UIColor? = nil) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = bgColor ?? UIColor.black.withAlphaComponent(0.4)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        button.layer.cornerRadius = 8
    }

    func clear() {
        self.gameScore.clear()
        self.gameBoard.clear()
        self.nextBrick.clearNextBricks()
        self.holdPiece.clear()
    }

    func prepare() {
        self.gameScore.clear()
        self.gameBoard.clear()
        self.nextBrick.clearNextBricks()
        self.holdPiece.clear()
    }
}
