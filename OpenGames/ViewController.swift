//
//  ViewController.swift
//  OpenGames
//
//  Created by yjlee12 on 2021/12/29.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var contentView = UIView()
    var swiftris:Swiftris!
    
    deinit {
        self.swiftris.deinitGame()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.backgroundColor = .red
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
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            self.swiftris.touch(touch)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }


}

