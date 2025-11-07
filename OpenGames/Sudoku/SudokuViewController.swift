//
//  SudokuViewController.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/30.
//

import Foundation
import UIKit
import AddThen
import SnapKit


func random(_ n:Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
} // end random()

class SudokuViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // UI Components
    private var PuzzleArea = SudokuView()
    private var noteToggleButton = UIButton()
    private var clearButton = UIButton()
    private var numberButtons: [UIButton] = []

    var PencilOn = false {
        didSet {
            updateNoteButtonAppearance()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PencilOn = false
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        initView()
        setupControlButtons()  // Must be called before setupKeypad()
        setupKeypad()           // Keypad depends on noteToggleButton position

        // Load saved game state if available
        loadSavedGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save game state when leaving the view
        saveGame()
    }

    private func loadSavedGame() {
        let puzzle = appDelegate.sudoku
        if puzzle.loadGameState() {
            // Successfully loaded saved state
            refresh()
        }
    }

    private func saveGame() {
        let puzzle = appDelegate.sudoku
        // Only save if there's an active puzzle
        if puzzle.inProgress {
            puzzle.saveGameState()
        }
    }

    private func initView() {
        navigationItem.title = "Sudoku"
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: "Easy", handler: {_ in
                self._Simple()
                self.refresh()
            }),
            UIAction(title: "Hard", handler: {_ in
                self._Hard()
                self.refresh()
            }),
            UIAction(title: "Clear All", handler: {_ in
                self.clearAll()
            })
        ])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, menu: menu)

        // Puzzle Area - Larger board
        view.addSubview(PuzzleArea)
        PuzzleArea.backgroundColor = .white
        PuzzleArea.layer.cornerRadius = 8
        PuzzleArea.layer.shadowColor = UIColor.black.cgColor
        PuzzleArea.layer.shadowOffset = CGSize(width: 0, height: 2)
        PuzzleArea.layer.shadowRadius = 4
        PuzzleArea.layer.shadowOpacity = 0.1

        PuzzleArea.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(8) // Less inset = bigger board
            make.height.equalTo(PuzzleArea.snp.width)
        }
    }

    private func setupKeypad() {
        let keypadContainer = UIView()
        keypadContainer.backgroundColor = .clear
        view.addSubview(keypadContainer)

        // Position keypad below control buttons with proper spacing, respecting safe area
        keypadContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(noteToggleButton.snp.bottom).offset(12)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.width.height.equalTo(210) // Smaller container for compact keypad
        }

        // Create 3x3 grid of number buttons (1-9) - Compact size
        for i in 1...9 {
            let button = UIButton(type: .system)
            button.setTitle("\(i)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26) // Smaller font
            button.backgroundColor = .white
            button.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0), for: .normal)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
            button.tag = i
            button.addTarget(self, action: #selector(Keypad(_:)), for: .touchUpInside)

            keypadContainer.addSubview(button)
            numberButtons.append(button)

            let row = (i - 1) / 3
            let col = (i - 1) % 3

            let buttonSize: CGFloat = 60 // Compact buttons
            let spacing: CGFloat = 15 // Less spacing

            button.snp.makeConstraints { make in
                make.width.height.equalTo(buttonSize)
                make.leading.equalToSuperview().offset(CGFloat(col) * (buttonSize + spacing))
                make.top.equalToSuperview().offset(CGFloat(row) * (buttonSize + spacing))
            }
        }
    }

    private func setupControlButtons() {
        // Note Mode Toggle Button
        noteToggleButton.setTitle("Note: OFF", for: .normal)
        noteToggleButton.setTitle("Note: ON", for: .selected)
        noteToggleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        noteToggleButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        noteToggleButton.setTitleColor(.darkGray, for: .normal)
        noteToggleButton.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), for: .selected)
        noteToggleButton.layer.cornerRadius = 8
        noteToggleButton.layer.borderWidth = 2
        noteToggleButton.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        noteToggleButton.addTarget(self, action: #selector(toggleNoteMode), for: .touchUpInside)

        view.addSubview(noteToggleButton)
        noteToggleButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(PuzzleArea.snp.bottom).offset(8)
            make.width.equalTo(110)
            make.height.equalTo(44)
        }

        // Clear Cell Button
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        clearButton.backgroundColor = UIColor(red: 0.95, green: 0.4, blue: 0.4, alpha: 1.0)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearCell(_:)), for: .touchUpInside)

        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.leading.equalTo(noteToggleButton.snp.trailing).offset(8)
            make.top.equalTo(PuzzleArea.snp.bottom).offset(8)
            make.width.equalTo(80)
            make.height.equalTo(44)
        }
    }

    @objc private func toggleNoteMode() {
        PencilOn = !PencilOn
        noteToggleButton.isSelected = PencilOn
    }

    private func updateNoteButtonAppearance() {
        if PencilOn {
            noteToggleButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.2)
            noteToggleButton.layer.borderColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor
        } else {
            noteToggleButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            noteToggleButton.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        }
    }

    private func clearAll() {
        let puzzle = appDelegate.sudoku
        puzzle.clearUserPuzzle()
        puzzle.clearPencilPuzzle()
        puzzle.gameInProgress(set: false)
        puzzle.clearSavedState() // Clear saved state
        refresh()
    }

    func refresh() {
        PuzzleArea.setNeedsDisplay()
    }
    
    func _Simple() {
        let puzzle = appDelegate.sudoku
        puzzle.grid.gameDiff = "simple"
        let array = appDelegate.getPuzzles(puzzle.grid.gameDiff)
        puzzle.grid.plistPuzzle = puzzle.plistToPuzzle(plist: array[random(array.count)], toughness: puzzle.grid.gameDiff)
        puzzle.clearUserPuzzle()
        puzzle.clearPencilPuzzle()
        puzzle.gameInProgress(set: true)
        puzzle.saveGameState() // Save new puzzle
    }

    func _Hard() {
        let puzzle = appDelegate.sudoku
        puzzle.grid.gameDiff = "hard"
        let array = appDelegate.getPuzzles(puzzle.grid.gameDiff)
        puzzle.grid.plistPuzzle = puzzle.plistToPuzzle(plist: array[random(array.count)], toughness: puzzle.grid.gameDiff)
        puzzle.clearUserPuzzle()
        puzzle.clearPencilPuzzle()
        puzzle.gameInProgress(set: true)
        puzzle.saveGameState() // Save new puzzle
    }
    
//    @IBAction func Continue(_ sender: Any) {
//        let puzzle = appDelegate.sudoku
//        let load = appDelegate.load
//        print("\(String(puzzle.inProgress))")
//        if puzzle.inProgress {
//            performSegue(withIdentifier: "toPuzzle", sender: sender)
//        } else if load != nil {
//            appDelegate.sudoku.grid = load
//            performSegue(withIdentifier: "toPuzzle", sender: sender)
//        } else {
//        let alert = UIAlertController(title: "Alert", message: "No Game in Progress & No Saved Games", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .`default`, handler: { _ in
//        }))
//        self.present(alert, animated: true, completion: nil)
//        }
//    }
    
//    @IBAction func leavePuzzle(_ sender: Any) {
//        // UIAlertController message
//        let title = "Leaving Current Game"
//        let message = "Are you sure you want to abandon?"
//        let button = "OK"
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString(button, comment: "Default action"), style: .`default`, handler: { _ in
//        
//            let puzzle = self.appDelegate.sudoku
//            puzzle.clearUserPuzzle()
//            puzzle.clearPlistPuzzle()
//            puzzle.clearPencilPuzzle()
//            puzzle.gameInProgress(set: false)
//            
//        self.navigationController?.popViewController(animated: true)
//
//        }))
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }


    @IBAction func Keypad(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = self.appDelegate.sudoku
        puzzle.gameInProgress(set: true)
        var grid = appDelegate.sudoku.grid
        let row = PuzzleArea.selected.row
        let col = PuzzleArea.selected.column
        if (row != -1 && col != -1) {
            if PencilOn == false {
                if grid?.plistPuzzle[row][col] == 0 && grid?.userPuzzle[row][col] == 0  {
                    appDelegate.sudoku.userGrid(n: sender.tag, row: row, col: col)
                    refresh()
                    puzzle.saveGameState() // Save after input
                } else if grid?.plistPuzzle[row][col] == 0 || grid?.userPuzzle[row][col] == sender.tag {
                    appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
                    refresh()
                    puzzle.saveGameState() // Save after clearing
                }
            } else {
                appDelegate.sudoku.pencilGrid(n: sender.tag, row: row, col: col)
                refresh()
                puzzle.saveGameState() // Save after note toggle
            }
        }
    }
    
    @IBAction func clearCell(_ sender: UIButton) {
        let row = PuzzleArea.selected.row
        let col = PuzzleArea.selected.column
        var grid = appDelegate.sudoku.grid

        if grid?.userPuzzle[row][col] != 0 {
            appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
        }

        for i in 0...9 {
            appDelegate.sudoku.pencilGridBlank(n: i, row: row, col: col)
        }
        refresh()
        appDelegate.sudoku.saveGameState() // Save after clearing cell
    }
}


