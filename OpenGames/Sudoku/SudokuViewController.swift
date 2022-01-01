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
    private var view1 = UIButton()
    private var view2 = UIButton()
    private var view3 = UIButton()
    private var view4 = UIButton()
    private var view5 = UIButton()
    private var view6 = UIButton()
    private var view7 = UIButton()
    private var view8 = UIButton()
    private var view9 = UIButton()
    private var view0 = UIButton()
    private var viewa = UIButton()
    private var viewb = UIButton()
    private var viewc = UIButton()
    private var PuzzleArea = SudokuView()
    

    var PencilOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        PencilOn = false
        view.backgroundColor = .white
        initView()
    }
    
    private func initView() {
        navigationItem.title = "sudoku"
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: "easy", handler: {_ in
                self._Simple()
                self.refresh()
            }),
            UIAction(title:"Hard", handler: {_ in
                self._Hard()
                self.refresh()
            }),
            UIAction(title:"reset", handler: {_ in
                
            })
        ])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, menu: menu)

    
        view.add(PuzzleArea) {
            $0.backgroundColor = .red
            $0.snp.makeConstraints { make in
                make.top.trailing.leading.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                make.width.equalTo(self.view.safeAreaLayoutGuide.snp.width).inset(16)
                make.height.equalTo(self.view.safeAreaLayoutGuide.snp.width).inset(16)
            }
        }
    }
    

    @IBAction func pencilOn(_ sender: UIButton) {
        PencilOn = !PencilOn
        sender.isSelected = PencilOn
    }
    
    func refresh() {
        PuzzleArea.setNeedsDisplay()
    }
    
    func _Simple() {
        let puzzle = appDelegate.sudoku
        puzzle.grid.gameDiff = "simple"
        let array = appDelegate.getPuzzles(puzzle.grid.gameDiff)
        puzzle.grid.plistPuzzle = puzzle.plistToPuzzle(plist: array[random(array.count)], toughness: puzzle.grid.gameDiff)
    }
    
    func _Hard() {
        let puzzle = appDelegate.sudoku
        puzzle.grid.gameDiff = "hard"
        let array = appDelegate.getPuzzles(puzzle.grid.gameDiff)
        puzzle.grid.plistPuzzle = puzzle.plistToPuzzle(plist: array[random(array.count)], toughness: puzzle.grid.gameDiff)
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
                } else if grid?.plistPuzzle[row][col] == 0 || grid?.userPuzzle[row][col] == sender.tag {
                    appDelegate.sudoku.userGrid(n: 0, row: row, col: col)
                    refresh()
                }
            } else {
                appDelegate.sudoku.pencilGrid(n: sender.tag, row: row, col: col)
                refresh()
            }
        }
    }
    
    @IBAction func MenuButton(_ sender: UIButton) {
        // UIAlertController message
        let alert = UIAlertController(title: "Menu", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear Conflicts", comment: "Default action"), style: .`default`, handler: { _ in
            
            let puzzle = self.appDelegate.sudoku
            puzzle.clearConflicts()
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear All", comment: ""), style: .`default`, handler: { _ in
            let puzzle = self.appDelegate.sudoku
            puzzle.clearUserPuzzle()
            puzzle.clearPencilPuzzle()
            puzzle.gameInProgress(set: false)
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
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
    }
}


