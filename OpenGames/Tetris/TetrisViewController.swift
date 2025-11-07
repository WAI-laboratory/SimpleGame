//
//  ViewController.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//

import UIKit
import SnapKit

class TetrisViewController: UIViewController {
    var contentView = UIView()
    var swiftris:Swiftris!
    
    deinit {
        self.swiftris.deinitGame()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        self.initializeGame()
    }

    func initializeGame() {
        // after layout pass, ensure GameView to make
        DispatchQueue.main.async {
            let gameView = GameView(self.contentView)
            self.swiftris = Swiftris(gameView: gameView)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }


}

