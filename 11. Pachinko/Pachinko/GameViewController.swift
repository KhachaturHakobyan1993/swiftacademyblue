//
//  GameViewController.swift
//  Pachinko
//
//  Created by Khachatur Hakobyan on 12/22/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    func setup() {
        guard let skView = self.view as? SKView,
            let scene = SKScene(fileNamed: "GameScene") else { return }
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = false
        skView.showsFPS = false
        skView.showsNodeCount = false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
