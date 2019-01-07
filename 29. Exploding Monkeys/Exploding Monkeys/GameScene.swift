//
//  GameScene.swift
//  Exploding Monkeys
//
//  Created by Khachatur Hakobyan on 1/7/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene {
    weak var viewController: GameViewController!
    var buildings = [BuildingNode]()
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    var currentPlayer = 1
    var scorePlayer1Label: SKLabelNode!
    var scorePlayer2Label: SKLabelNode!
    var scorePlayer1 = 0 { didSet { self.scorePlayer1Label?.text = "Player1 Score: \(self.scorePlayer1)"}}
    var scorePlayer2 = 0 { didSet { self.scorePlayer2Label?.text = "Player2 Score: \(self.scorePlayer2)" }}

    
    override func didMove(to view: SKView) {
        self.setup()
        self.createBuildings()
        self.createPlayers()
        self.createScoreLabels()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.update()
    }
    
    
    // MARK: - Methods Setup -

    private func setup() {
        self.backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        self.physicsWorld.contactDelegate = self
        self.viewController.activatePlayer(number: self.currentPlayer)
    }
    
    
    // MARK: - Methods -
    
    func createScoreLabels() {
        self.scorePlayer1Label = SKLabelNode(fontNamed: "Chalkduster")
        self.scorePlayer1Label.fontSize = 30
        self.scorePlayer1Label.fontColor = UIColor.black
        self.scorePlayer1Label.text = "Player1 Score: \(self.scorePlayer1)"
        self.scorePlayer1Label.horizontalAlignmentMode = .left
        self.addChild(self.scorePlayer1Label)
        self.scorePlayer1Label.position = CGPoint(x: 16, y: 50)
        self.scorePlayer1Label.zPosition = 2
        
        self.scorePlayer2Label = SKLabelNode(fontNamed: "Chalkduster")
        self.scorePlayer2Label.fontSize = 30
        self.scorePlayer2Label.fontColor = UIColor.black
        self.scorePlayer2Label.text =  "Player2 Score: \(self.scorePlayer1)"
        self.scorePlayer2Label.horizontalAlignmentMode = .left
        self.addChild(self.scorePlayer2Label)
        self.scorePlayer2Label.position = CGPoint(x: 16, y: 16)
        self.scorePlayer2Label.zPosition = 2
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40,
                              height: Int.random(in: 300...600))
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX + (size.width / 2), y: size.height / 2)
            building.setup()
            self.addChild(building)
            currentX += size.width + 2

            self.buildings.append(building)
        }
    }
    
    func createPlayers() {
        self.player1 = SKSpriteNode(imageNamed: "player")
        self.player1.name = "player1"
        self.player1.physicsBody = SKPhysicsBody(circleOfRadius: self.player1.size.width / 2)
        self.player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        self.player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        self.player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        self.player1.physicsBody?.isDynamic = false
        
        let player1Building = self.buildings[1]
        self.player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + self.player1.size.height) / 2))
        self.addChild(self.player1)
        
        self.player2 = SKSpriteNode(imageNamed: "player")
        self.player2.name = "player2"
        self.player2.physicsBody = SKPhysicsBody(circleOfRadius: self.player2.size.width / 2)
        self.player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        self.player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        self.player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        self.player2.physicsBody?.isDynamic = false
        
        let player2Building = self.buildings[self.buildings.count - 2]
        self.player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + self.player2.size.height) / 2))
        self.addChild(self.player2)
    }
    
    private func update() {
        guard self.banana != nil,
            self.banana.position.y < -1000 else { return }
        self.banana.removeFromParent()
        self.banana = nil
        self.changePlayer()
    }
    
    func launch(angle: Int, velocity: Int) {
        
        func createBanana() {
            if self.banana != nil {
                self.banana.removeFromParent()
                self.banana = nil
            }
            
            self.banana = SKSpriteNode(imageNamed: "banana")
            self.banana.name = "banana"
            self.banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
            self.banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
            self.banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
            self.banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
            self.banana.physicsBody?.usesPreciseCollisionDetection = true
            self.addChild(banana)
        }
        
        // 1
        let speed = Double(velocity) / 10.0
        
        // 2
        let radians = self.deg2rad(degrees: angle)
        
        // 3
        createBanana()
        
        if self.currentPlayer == 1 {
            // 4
            self.banana.position = CGPoint(x: self.player1.position.x - 30, y: self.player1.position.y + 40)
            self.banana.physicsBody?.angularVelocity = -20
            
            // 5
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            self.player1.run(sequence)
            
            // 6
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            self.banana.physicsBody?.applyImpulse(impulse)
        } else {
            // 7
            self.banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            self.banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            self.player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            self.banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180.0
    }
    
    func destroy(player: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        self.addChild(explosion)
        
        player.removeFromParent()
        self.banana?.removeFromParent()
        
        let isWin = self.scorePlayer1 == 5 || self.scorePlayer2 == 5
        if isWin { self.showWinAlert() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame

            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
            if !isWin {
                newGame.scorePlayer1 = self.scorePlayer1
                newGame.scorePlayer2 = self.scorePlayer2
            }
        }
    }
    
    func changePlayer() {
        self.currentPlayer = (currentPlayer == 1 ? 2 : 1)
        self.viewController.activatePlayer(number: self.currentPlayer)
    }
    
    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        let buildingLocation = self.convert(contactPoint, to: building)
        building.hitAt(point: buildingLocation)
        
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        self.addChild(explosion)
        
        self.banana.name = ""
        self.banana?.removeFromParent()
        self.banana = nil
        
        self.changePlayer()
    }
    
    func showWinAlert() {
        let winLabel = SKLabelNode(fontNamed: "Chalkduster")
        winLabel.fontSize = 40
        winLabel.fontColor = UIColor.red
        let title = (self.scorePlayer1 == 5 ? "Player1 WIN" : "Player2 WIN")
        winLabel.text = title
        winLabel.horizontalAlignmentMode = .center
        self.addChild(winLabel)
        winLabel.position = CGPoint(x: self.scene!.frame.midX, y: self.scene!.frame.height - 40)
        winLabel.zPosition = 2
        let wait = SKAction.wait(forDuration: 8)
        let remove = SKAction.run { winLabel.removeFromParent() }
        let sequence = SKAction.sequence([wait, remove])
        winLabel.run(sequence)
    }
}


// MARK: - SKPhysicsContactDelegate -

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node,
            let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            self.scorePlayer2 += 1
            self.destroy(player: self.player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            self.scorePlayer1 += 1
            self.destroy(player: self.player2)
        }
    }
}
