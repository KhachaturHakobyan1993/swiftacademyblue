//
//  GameScene.swift
//  Marble Maze
//
//  Created by Khachatur Hakobyan on 1/5/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

enum GameType: String {
    case block = "x"
    case vortex = "v"
    case star = "s"
    case finish = "f"
    case player = "p"
    
    var collisionType: UInt32 {
        switch self {
        case .block: return 1
        case .vortex: return 2
        case .star: return 4
        case .finish: return 8
        case .player: return 16
        }
    }
}

class GameScene: SKScene {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var score = 0 { didSet { self.scoreLabel.text = "Score: \(self.score)" } }
    var level = 1
    var isGameOver = false
    
    
    override func didMove(to view: SKView) {
        self.setupMotionManager()
        self.loadLevel()
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if targetEnvironment(simulator)
        guard let currentTouch = self.lastTouchPosition else { return }
        let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
        self.physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        #else
        guard let accelerometerData = self.motionManager.accelerometerData else { return }
        self.physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        #endif
    }
    
    
    // MARK: - Methods Setup -

    private func setupWithRemoveAll() {
        self.removeAllChildren()
        self.setup()
        self.createPlayer()
    }
    
    private func setup() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: self.scene!.frame.midX, y: self.scene!.frame.midY)
        background.blendMode = .replace
        background.zPosition = -1
        self.addChild(background)
        
        self.scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.horizontalAlignmentMode = .left
        self.scoreLabel.position = CGPoint(x: 16, y: 16)
        self.addChild(self.scoreLabel)
        
        self.physicsWorld.contactDelegate = self
    }
    
    private func setupMotionManager() {
        self.motionManager = CMMotionManager()
        self.motionManager.startAccelerometerUpdates()
    }
    
    @objc func loadLevel() {
        self.setupWithRemoveAll()
        
        guard let levelPath = Bundle.main.path(forResource: "level\(self.level)", ofType: "txt"),
            let levelString = try? String(contentsOfFile: levelPath) else { return }
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                guard let gameType = GameType(rawValue: String(letter)),
                    gameType != .player else { continue }
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
            
                switch gameType {
                case .block: self.createBlock(position)
                case .vortex: self.createVortex(position)
                case .star: self.createStar(position)
                case .finish: self.createFinish(position)
                case .player: break
                }
            }
        }
    }
    
    func createBlock(_ position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = GameType.block.collisionType
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        self.addChild(node)
    }
    
    func createVortex(_ position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = GameType.vortex.collisionType
        node.physicsBody?.contactTestBitMask = GameType.player.collisionType
        node.physicsBody?.collisionBitMask = 0
        self.addChild(node)
    }
    
    func createStar(_ position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = GameType.star.collisionType
        node.physicsBody?.contactTestBitMask = GameType.player.collisionType
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        self.addChild(node)
    }
    
    func createFinish(_ position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = GameType.finish.collisionType
        node.physicsBody?.contactTestBitMask = GameType.player.collisionType
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        self.addChild(node)
    }
    
    func createPlayer() {
        self.player = SKSpriteNode(imageNamed: "player")
        self.player.position = CGPoint(x: 96, y: self.scene!.frame.height - 96)
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: self.player.size.width / 2)
        self.player.physicsBody?.allowsRotation = false
        self.player.physicsBody?.linearDamping = 0.5
        
        self.player.physicsBody?.categoryBitMask = GameType.player.collisionType
        self.player.physicsBody?.contactTestBitMask = GameType.star.collisionType | GameType.vortex.collisionType | GameType.finish.collisionType
        self.player.physicsBody?.collisionBitMask = GameType.block.collisionType
        self.addChild(self.player)
    }
    
    
    // MARK: - Touches Handler -

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchPosition = nil
    }
    
    
    // MARK: - Methods -
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            self.player.physicsBody?.isDynamic = false
            self.isGameOver = true
            self.score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            self.player.run(sequence) { [unowned self] in
                self.createPlayer()
                self.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            self.score += 1
        } else if node.name == "finish" {
            self.score = 0
            self.level += 1
            DispatchQueue.main.async {
                self.loadLevel()
            }
        }
    }
}


// MARK: - SKPhysicsContactDelegate -

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == self.player {
            self.playerCollided(with: contact.bodyB.node!)
        } else if contact.bodyB.node == self.player {
            self.playerCollided(with: contact.bodyA.node!)
        }
    }
}
