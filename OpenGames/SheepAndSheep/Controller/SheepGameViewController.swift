//
//  SheepGameViewController.swift
//  OpenGames
//
//  Created by Claude on 2025/11/08.
//

import UIKit
import SnapKit

class SheepGameViewController: UIViewController {
    // UI Components
    private let gameBoardView = GameBoardView()
    private let collectionSlotView = CollectionSlotView()
    private let scoreLabel = UILabel()
    private let levelLabel = UILabel()

    // Power-up buttons
    private let undoButton = UIButton(type: .system)
    private let shuffleButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    // Power-up counts
    private var undoCount = 3
    private var shuffleCount = 2
    private var removeCount = 2

    // Game state
    private var gameBoard: SheepGameBoard!
    private var removedTiles: [Tile] = []  // For remove power-up

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.9, blue: 0.85, alpha: 1.0)
        navigationItem.title = "Sheep and Sheep"

        setupUI()
        setupMenu()
        startNewGame(level: 1)
    }

    private func setupUI() {
        // Score and level labels
        let topBar = UIView()
        topBar.backgroundColor = UIColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        view.addSubview(topBar)

        topBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }

        levelLabel.text = "Level 1"
        levelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        levelLabel.textColor = .white
        topBar.addSubview(levelLabel)

        levelLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textColor = .white
        topBar.addSubview(scoreLabel)

        scoreLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        // Game board
        view.addSubview(gameBoardView)
        gameBoardView.delegate = self

        gameBoardView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(400)
        }

        // Collection slot view at bottom
        view.addSubview(collectionSlotView)

        collectionSlotView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(80)
        }

        // Power-up buttons
        setupPowerUpButtons()
    }

    private func setupPowerUpButtons() {
        let buttonContainer = UIView()
        view.addSubview(buttonContainer)

        buttonContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(collectionSlotView.snp.top).offset(-16)
            make.height.equalTo(60)
        }

        // Undo button
        configureButton(undoButton, title: "↶ Undo", color: UIColor.systemBlue)
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        buttonContainer.addSubview(undoButton)

        undoButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }

        // Shuffle button
        configureButton(shuffleButton, title: "🔀 Shuffle", color: UIColor.systemGreen)
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        buttonContainer.addSubview(shuffleButton)

        shuffleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }

        // Remove button
        configureButton(removeButton, title: "🗑 Remove", color: UIColor.systemOrange)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        buttonContainer.addSubview(removeButton)

        removeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }

        updatePowerUpButtons()
    }

    private func configureButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
    }

    private func setupMenu() {
        let menu = UIMenu(title: "Game Options", children: [
            UIAction(title: "Level 1 (Tutorial)", handler: { _ in
                self.startNewGame(level: 1)
            }),
            UIAction(title: "Level 2", handler: { _ in
                self.startNewGame(level: 2)
            }),
            UIAction(title: "Level 3", handler: { _ in
                self.startNewGame(level: 3)
            }),
            UIAction(title: "Level 4", handler: { _ in
                self.startNewGame(level: 4)
            }),
            UIAction(title: "Restart", handler: { _ in
                self.restartLevel()
            })
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, menu: menu)
    }

    // MARK: - Game Logic

    private func startNewGame(level: Int) {
        gameBoard = LevelGenerator.generateLevel(level)
        gameBoardView.gameBoard = gameBoard
        collectionSlotView.tiles = []

        // Reset power-ups
        undoCount = 3
        shuffleCount = 2
        removeCount = 2
        updatePowerUpButtons()

        updateUI()
        saveGame()
    }

    private func restartLevel() {
        guard let level = gameBoard?.level else { return }
        startNewGame(level: level)
    }

    private func updateUI() {
        guard let gameBoard = gameBoard else { return }

        levelLabel.text = "Level \(gameBoard.level)"
        scoreLabel.text = "Score: \(gameBoard.score)"
        collectionSlotView.tiles = gameBoard.collectionSlots

        // Check game state
        if gameBoard.state == .won {
            showVictory()
        } else if gameBoard.state == .lost {
            showGameOver()
        }
    }

    private func updatePowerUpButtons() {
        undoButton.setTitle("↶ Undo (\(undoCount))", for: .normal)
        shuffleButton.setTitle("🔀 Shuffle (\(shuffleCount))", for: .normal)
        removeButton.setTitle("🗑 Remove (\(removeCount))", for: .normal)

        undoButton.isEnabled = undoCount > 0 && (gameBoard?.canUndo() ?? false)
        shuffleButton.isEnabled = shuffleCount > 0
        removeButton.isEnabled = removeCount > 0

        undoButton.alpha = undoButton.isEnabled ? 1.0 : 0.5
        shuffleButton.alpha = shuffleButton.isEnabled ? 1.0 : 0.5
        removeButton.alpha = removeButton.isEnabled ? 1.0 : 0.5
    }

    // MARK: - Power-Ups

    @objc private func undoTapped() {
        guard undoCount > 0 else { return }
        guard gameBoard.undo() else { return }

        undoCount -= 1
        gameBoardView.refreshDisplay()
        updateUI()
        updatePowerUpButtons()
        saveGame()
    }

    @objc private func shuffleTapped() {
        guard shuffleCount > 0 else { return }

        shuffleCount -= 1
        gameBoard.shuffle()
        gameBoardView.refreshDisplay()
        updatePowerUpButtons()
        saveGame()
    }

    @objc private func removeTapped() {
        guard removeCount > 0 else { return }
        guard !gameBoard.collectionSlots.isEmpty else { return }

        removeCount -= 1
        removedTiles = gameBoard.removeTilesFromCollection()

        // Show removed tiles briefly then restore to board
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameBoard.restoreTilesToBoard(self.removedTiles)
            self.gameBoardView.refreshDisplay()
            self.removedTiles.removeAll()
        }

        updateUI()
        updatePowerUpButtons()
        saveGame()
    }

    // MARK: - Game Over / Victory

    private func showVictory() {
        let alert = UIAlertController(
            title: "🎉 Victory!",
            message: "Congratulations! You cleared all tiles!\n\nScore: \(gameBoard.score)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Next Level", style: .default) { _ in
            self.startNewGame(level: self.gameBoard.level + 1)
        })

        alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartLevel()
        })

        present(alert, animated: true)
    }

    private func showGameOver() {
        let alert = UIAlertController(
            title: "💔 Game Over",
            message: "Collection slots are full!\n\nScore: \(gameBoard.score)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartLevel()
        })

        alert.addAction(UIAlertAction(title: "Main Menu", style: .cancel) { _ in
            self.startNewGame(level: 1)
        })

        present(alert, animated: true)
    }

    // MARK: - Persistence

    private func saveGame() {
        guard let gameBoard = gameBoard else { return }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameBoard) {
            UserDefaults.standard.set(encoded, forKey: "SheepGameState")
        }

        UserDefaults.standard.set(undoCount, forKey: "SheepUndoCount")
        UserDefaults.standard.set(shuffleCount, forKey: "SheepShuffleCount")
        UserDefaults.standard.set(removeCount, forKey: "SheepRemoveCount")
    }

    private func loadGame() {
        guard let savedData = UserDefaults.standard.data(forKey: "SheepGameState") else { return }

        let decoder = JSONDecoder()
        if let loadedBoard = try? decoder.decode(SheepGameBoard.self, from: savedData) {
            gameBoard = loadedBoard
            gameBoardView.gameBoard = gameBoard

            undoCount = UserDefaults.standard.integer(forKey: "SheepUndoCount")
            shuffleCount = UserDefaults.standard.integer(forKey: "SheepShuffleCount")
            removeCount = UserDefaults.standard.integer(forKey: "SheepRemoveCount")

            updateUI()
            updatePowerUpButtons()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if gameBoard == nil {
            loadGame()
            if gameBoard == nil {
                startNewGame(level: 1)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveGame()
    }
}

// MARK: - GameBoardViewDelegate

extension SheepGameViewController: GameBoardViewDelegate {
    func didSelectTile(_ tile: Tile) {
        guard gameBoard.selectTile(tile) else { return }

        // Animate tile to collection
        let slotIndex = gameBoard.collectionSlots.count - 1
        let targetPosition = collectionSlotView.getPositionForSlot(slotIndex)

        gameBoardView.animateTileToCollection(tile, toPosition: targetPosition) {
            self.updateUI()
            self.gameBoardView.highlightAccessibleTiles()
            self.updatePowerUpButtons()
            self.saveGame()
        }
    }
}
