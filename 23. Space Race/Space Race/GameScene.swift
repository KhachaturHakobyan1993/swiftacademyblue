//
//  GameScene.swift
//  Space Race
//
//  Created by Khachatur Hakobyan on 1/4/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 { didSet { self.scoreLabel.text = "Score: \(self.score)"}}
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false
    
    
    override func didMove(to view: SKView) {
        self.setup()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.update()
    }
    
    
    // MARK: - Methods Touch Handling -

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.movePlayer(touches)
    }
    
    
    // MARK: - Methods Setup -
    
    private func setup() {
        self.backgroundColor = UIColor.black
        
        self.starField = SKEmitterNode(fileNamed: "Starfield")!
        self.starField.position = CGPoint(x: self.scene!.frame.width, y: self.scene!.frame.midY)
        self.starField.advanceSimulationTime(10)
        self.addChild(self.starField)
        self.starField.zPosition = -1
        
        self.player = SKSpriteNode(imageNamed: "player")
        self.player.position = CGPoint(x: 100, y: self.scene!.frame.midY)
        self.player.physicsBody = SKPhysicsBody(texture: self.player.texture!, size: self.player.size)
        self.player.physicsBody?.contactTestBitMask = 1
        self.addChild(self.player)

        self.scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreLabel.position = CGPoint(x: 16, y: 16)
        self.scoreLabel.horizontalAlignmentMode = .left
        self.addChild(self.scoreLabel)

        self.score = 0
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.createEnemy), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Methods -
    
    @objc private func createEnemy() {
        self.possibleEnemies.shuffle()
        
        let sprite = SKSpriteNode(imageNamed: self.possibleEnemies[0])
        let xPosition = self.scene!.frame.width + 200
        let yBottomEdge = self.scoreLabel.frame.height + 16 + 20
        let yTopEdge = self.scene!.frame.height - 50
        let yPosition =  CGFloat.random(in: yBottomEdge...yTopEdge)
        sprite.position = CGPoint(x: xPosition, y: yPosition)
        self.addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    private func update() {
        for oneEnemy in self.children {
            guard oneEnemy.position.x < -300 else { continue }
            oneEnemy.removeFromParent()
            guard !self.isGameOver else { continue }
            self.score += 1
        }
    }
    
    private func movePlayer(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        if location.y < 100 {
            location.y = 100
        } else if location.y > self.scene!.frame.height - 100 {
            location.y = self.scene!.frame.height - 100
        }
        self.player.position = location
    }
    
    func startExplosion() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = self.player.position
        self.addChild(explosion)
        self.player.removeFromParent()
        self.isGameOver = true
    }
}


// MARK: - SKPhysicsContactDelegate -

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        self.startExplosion()
    }
}

