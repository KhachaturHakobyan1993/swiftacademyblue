//
//  GameScene.swift
//  Whack-a-Penguin
//
//  Created by Khachatur Hakobyan on 12/31/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    var score = 0 { didSet { self.gameScore.text = "Score: \(self.score)" } }
    var slots = [WhackSlot]()
    var popupTime = 0.85
    var numRounds = 0

    
    override func didMove(to view: SKView) {
        self.setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.monitoring(touches)
    }
    
    
    // MARK: - Methods -

    private func setup() {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.blendMode = .replace
        background.zPosition = -1
        self.addChild(background)
        
        self.gameScore = SKLabelNode(fontNamed: "Chalkduster")
        self.gameScore.text = "Score: 0"
        self.gameScore.position = CGPoint(x: 8, y: 8)
        self.gameScore.horizontalAlignmentMode = .left
        self.gameScore.fontSize = 48
        self.addChild(self.gameScore)
        
        for i in 0 ..< 5 { self.createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { self.createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { self.createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { self.createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.createEnemy()
        }
    }

    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        self.slots.append(slot)
    }
    
    func createEnemy() {
        self.numRounds += 1
        
        if self.numRounds >= 30 {
            for slot in self.slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            self.addChild(gameOver)
            
            return
        }
        
        self.popupTime *= 0.991
        
        self.slots.shuffle()
        self.slots[0].show(hideTime: self.popupTime)
        
        if Int.random(in: 0...12) > 4 { self.slots[1].show(hideTime: self.popupTime) }
        if Int.random(in: 0...12) > 8 {  self.slots[2].show(hideTime: self.popupTime) }
        if Int.random(in: 0...12) > 10 { self.slots[3].show(hideTime: self.popupTime) }
        if Int.random(in: 0...12) > 11 { self.slots[4].show(hideTime: self.popupTime)  }
        
        let minDelay = self.popupTime / 2.0
        let maxDelay = self.popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func monitoring(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = self.nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                let whackSlot = node.parent!.parent as! WhackSlot
                if !whackSlot.isVisible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.hit()
                self.score -= 5
                self.run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion:false))
            } else if node.name == "charEnemy" {
                // they should have whacked this one
                let whackSlot = node.parent!.parent as! WhackSlot
                if !whackSlot.isVisible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                whackSlot.hit()
                self.score += 1
                
                self.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion:false))
            }
        }
    }

}
