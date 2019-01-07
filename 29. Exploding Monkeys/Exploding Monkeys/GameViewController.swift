//
//  GameViewController.swift
//  Exploding Monkeys
//
//  Created by Khachatur Hakobyan on 1/7/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumberLabel: UILabel!
    var currentGame: GameScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupGameScene()
    }

    
    // MARK: - Methods Override -
    
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
    
    
    // MARK: - Methods Setup -

    private func setup() {
        self.angleSliderChanged(self.angleSlider)
        self.velocitySliderChanged(self.velocitySlider)
    }
    
    private func setupGameScene() {
        guard let skView = self.view as? SKView,
            let gameScene = GameScene(fileNamed: "GameScene") else { return }
        self.currentGame = gameScene
        self.currentGame.viewController = self
        self.currentGame.scaleMode = .aspectFill
        skView.presentScene(self.currentGame)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    // MARK: - Methods -
    
    func activatePlayer(number: Int) {
        self.playerNumberLabel.text = (number == 1 ? "<<< PLAYER ONE" : "PLAYER TWO >>>")
        self.setSettingsHidden(false)
    }
    
    private func setSettingsHidden(_ hidden: Bool) {
        self.angleSlider.isHidden = hidden
        self.angleLabel.isHidden = hidden
        self.velocitySlider.isHidden = hidden
        self.velocityLabel.isHidden = hidden
        self.launchButton.isHidden = hidden
    }
    
    
    // MARK: - IBActions -
    
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        self.angleLabel.text = "Angle: \(Int(sender.value))°"
    }
    
    @IBAction func velocitySliderChanged(_ sender: UISlider) {
        self.velocityLabel.text = "Velocity: \(Int(sender.value))"
    }
    
    @IBAction func launchButtonTapped(_ sender: UIButton) {
        self.setSettingsHidden(true)
        self.currentGame.launch(angle: Int(self.angleSlider.value), velocity: Int(self.velocitySlider.value))
    }
}

