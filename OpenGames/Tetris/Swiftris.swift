//
//  Swiftris.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//
import UIKit


enum GameState:Int {
    case stop = 0
    case play
    case pause
}

class Swiftris: NSObject {
    // Notification
    static var LineClearNotification                   = "LineClearNotification"
    static var NewBrickDidGenerateNotification         = "NewBrickDidGenerateNotification"
    static var GameStateChangeNotification             = "GameStateChangeNotification"
    static var LevelUpNotification                     = "LevelUpNotification"

    // font
    static func GameFont(_ fontSize:CGFloat) -> UIFont! {
        return UIFont(name: "ChalkboardSE-Regular", size: fontSize)
    }

    var gameView:GameView!
    var gameTimer:GameTimer!
    var soundManager:SoundManager!

    var gameState = GameState.stop
    var currentLevel = 0
    var dropSpeed = 20 // Number of frames before piece drops (higher = slower)

    required init(gameView:GameView) {
        super.init()
        self.gameView = gameView
        self.initGame()
    }

    deinit {
        debugPrint("deinit Swiftris")
    }

    fileprivate func initGame() {
        self.gameTimer = GameTimer(target: self, selector: #selector(Swiftris.gameLoop))
        self.soundManager = SoundManager()

        self.addGameStateChangeNotificationAction(#selector(Swiftris.gameStateChange(_:)))
        self.addLevelUpNotificationAction(#selector(Swiftris.levelUp(_:)))

        // Setup control buttons (Play, Pause, Stop)

        self.gameView.delegate = self

        // Setup movement buttons (Left, Right, Down)
        self.gameView.leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        self.gameView.rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        self.gameView.downButton.addTarget(self, action: #selector(softDrop), for: .touchUpInside)

        // Add continuous press for down button
        let downPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(downButtonPressed(_:)))
        downPressGesture.minimumPressDuration = 0.1
        self.gameView.downButton.addGestureRecognizer(downPressGesture)

        // Setup action buttons (Rotate Left, Rotate Right, Hard Drop, Hold)
        self.gameView.rotateLeftButton.addTarget(self, action: #selector(rotateLeft), for: .touchUpInside)
        self.gameView.rotateRightButton.addTarget(self, action: #selector(rotateRight), for: .touchUpInside)
        self.gameView.hardDropButton.addTarget(self, action: #selector(hardDrop), for: .touchUpInside)
        self.gameView.holdButton.addTarget(self, action: #selector(holdPiece), for: .touchUpInside)
    }

    func deinitGame() {
        self.stop()
        self.removeGameStateChangeNotificationAction()

        self.soundManager?.clear()
        self.gameTimer = nil
        self.soundManager = nil
        self.gameView = nil
    }

    @objc func gameStateChange(_ noti:Notification) {
        guard let userInfo = noti.userInfo as? [String:NSNumber] else { return }
        guard let rawValue = userInfo["gameState"] else { return }
        guard let toState = GameState(rawValue: rawValue.intValue) else { return }

        switch self.gameState {
        case .play:
            // pause
            if toState == GameState.pause {
                self.pause()
            }
            // stop
            if toState == GameState.stop {
                self.stop()
            }
        case .pause:
            // resume game
            if toState == GameState.play {
                self.play()
            }
            // stop
            if toState == GameState.stop {
                self.stop()
            }
        case .stop:
            // start game
            if toState == GameState.play {
                self.prepare()
                self.play()
            }
        }
    }


    @objc func gameLoop() {
        self.update()
        self.gameView.setNeedsDisplay()
    }

    fileprivate func update() {
        self.gameTimer.counter += 1

        // Drop speed decreases as level increases (faster falling)
        if self.gameTimer.counter % dropSpeed == (dropSpeed - 1) {
            let game = self.gameView.gameBoard.update()
            if game.isGameOver {
                self.gameOver()
                return
            }
        }
    }

    @objc func levelUp(_ noti: Notification) {
        guard let userInfo = noti.userInfo as? [String: NSNumber] else { return }
        guard let level = userInfo["level"] else { return }

        currentLevel = level.intValue
        // Speed increases with level: starts at 20, decreases by 2 each level, minimum 4
        dropSpeed = max(4, 20 - (currentLevel * 2))
    }

    fileprivate func prepare() {
        self.currentLevel = 0
        self.dropSpeed = 20
        self.gameView.prepare()
        self.gameView.gameBoard.generateBrick()
    }

    fileprivate func play() {
        self.gameState = GameState.play
        self.gameTimer.start()
        self.soundManager?.playBGM()
    }

    fileprivate func pause() {
        self.gameState = GameState.pause
        self.gameTimer.pause()
        self.soundManager?.pauseBGM()
    }

    fileprivate func stop() {
        self.gameState = GameState.stop
        self.gameTimer.pause()
        self.soundManager?.stopBGM()

        self.gameView.clear()
    }

    fileprivate func gameOver() {
        self.gameState = GameState.stop
        self.gameTimer.pause()
        self.soundManager?.stopBGM()
        self.soundManager?.gameOver()

//        self.gameView.nextBrick.clearButtons()
    }

    // MARK: - Control Button Actions
    @objc func playGame() {
        if gameState == .stop {
            self.prepare()
            self.play()
        } else if gameState == .pause {
            self.play()
        }
    }

    @objc func pauseGame() {
        if gameState == .play {
            self.pause()
        }
    }

    @objc func stopGame() {
        if gameState == .play || gameState == .pause {
            self.stop()
        }
    }

    // MARK: - Movement Controls
    @objc func moveLeft() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        self.gameView.gameBoard.updateX(-1)
    }

    @objc func moveRight() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        self.gameView.gameBoard.updateX(1)
    }

    @objc func softDrop() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        self.gameView.gameBoard.softDrop()
    }

    @objc func downButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        guard self.gameState == GameState.play else { return }

        if gesture.state == .began || gesture.state == .changed {
            self.softDrop()
        }
    }

    @objc func hardDrop() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        self.gameView.gameBoard.dropBrick()
        self.soundManager?.dropBrick()
    }

    // MARK: - Rotation Controls
    @objc func rotateRight() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        self.gameView.gameBoard.rotateBrick()
    }

    @objc func rotateLeft() {
        guard self.gameState == GameState.play else { return }
        guard let currentBrick = self.gameView.gameBoard.currentBrick else { return }

        // Rotate left = rotate right 3 times
        let rotatedPoints1 = currentBrick.rotatedPoints()
        if self.gameView.gameBoard.canRotate(currentBrick, rotatedPoints: rotatedPoints1) {
            currentBrick.points = rotatedPoints1

            let rotatedPoints2 = currentBrick.rotatedPoints()
            if self.gameView.gameBoard.canRotate(currentBrick, rotatedPoints: rotatedPoints2) {
                currentBrick.points = rotatedPoints2

                let rotatedPoints3 = currentBrick.rotatedPoints()
                if self.gameView.gameBoard.canRotate(currentBrick, rotatedPoints: rotatedPoints3) {
                    currentBrick.points = rotatedPoints3
                    self.gameView.setNeedsDisplay()
                }
            }
        }
    }

    // MARK: - Hold Feature
    @objc func holdPiece() {
        guard self.gameState == GameState.play else { return }
        if let held = self.gameView.gameBoard.holdCurrentBrick() {
            self.gameView.holdPiece.heldBrick = held
        }
    }

    // MARK: - Notification Observers
    fileprivate func addGameStateChangeNotificationAction(_ action:Selector) {
        NotificationCenter.default.addObserver(self,
                                                         selector: action,
                                                         name: NSNotification.Name(rawValue: Swiftris.GameStateChangeNotification),
                                                         object: nil)
    }

    fileprivate func addLevelUpNotificationAction(_ action:Selector) {
        NotificationCenter.default.addObserver(self,
                                                         selector: action,
                                                         name: NSNotification.Name(rawValue: Swiftris.LevelUpNotification),
                                                         object: nil)
    }

    fileprivate func removeGameStateChangeNotificationAction() {
        NotificationCenter.default.removeObserver(self)
    }
}


extension Swiftris: GameViewDelegate {
    func didSelectPlay() {
        self.playGame()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: Swiftris.GameStateChangeNotification),
            object: nil,
            userInfo: ["gameState":NSNumber(value: gameState.rawValue as Int)]
        )
    }
    
    func didSelectPause() {
        self.pauseGame()
    }
    
    func didSelectStop() {
        self.stopGame()
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: Swiftris.GameStateChangeNotification),
            object: nil,
            userInfo: ["gameState":NSNumber(value: GameState.stop.rawValue as Int)]
        )
    }
    
}
