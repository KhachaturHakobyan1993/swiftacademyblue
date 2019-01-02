//
//  GameScene.swift
//  Fireworks Night
//
//  Created by Khachatur Hakobyan on 1/2/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer!
    var fireworks = [SKNode]()
    var leftEdge = 22
    var rightEdge = 1024 + 22
    var bottomEdge = -22
    var scoreLabel: SKLabelNode!
    var score = 0 { didSet { self.scoreLabel.text = "Score: \(self.score)" } }
    
    
    override func didMove(to view: SKView) {
        self.setupBackground()
        self.setupTimer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.update()
    }
    
    
    // MARK: - Methods Touch Handling -

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.checkTouches(touches)
    }
    
    
    
    
    // MARK: - Methods Setup -
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.view!.bounds.midX, y: self.view!.bounds.midY)
        background.blendMode = .replace
        background.zPosition = -1
        self.addChild(background)
        
        self.scoreLabel = SKLabelNode(fontNamed: UIFont.familyNames[0])
        self.scoreLabel.position = CGPoint(x: 8, y: 8)
        self.scoreLabel.fontSize = 48
        self.scoreLabel.horizontalAlignmentMode = .left
        self.scoreLabel.text = "Score: 0"
        self.addChild(self.scoreLabel)
    }
    
    private func setupTimer() {
        self.gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(GameScene.launchFirework), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Methods -
    
    private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let moveAction = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(moveAction)
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        self.fireworks.append(node)
        self.addChild(node)
    }
    
    @objc private func launchFirework() {
        let movementAmount: CGFloat = 1000
        
        switch Int.random(in: 0...3) {
        case 0:
            self.createFirework(xMovement: 0, x: 512, y: self.bottomEdge)
            self.createFirework(xMovement: 0, x: 512 - 200, y: self.bottomEdge)
            self.createFirework(xMovement: 0, x: 512 - 100, y: self.bottomEdge)
            self.createFirework(xMovement: 0, x: 512 + 100, y: self.bottomEdge)
            self.createFirework(xMovement: 0, x: 512 + 200, y: self.bottomEdge)
        case 1:
            self.createFirework(xMovement: 0, x: 512, y: self.bottomEdge)
            self.createFirework(xMovement: -200, x: 512 - 200, y: self.bottomEdge)
            self.createFirework(xMovement: -100, x: 512 - 100, y: self.bottomEdge)
            self.createFirework(xMovement: 100, x: 512 + 100, y: self.bottomEdge)
            self.createFirework(xMovement: 200, x: 512 + 200, y: self.bottomEdge)
        case 2:
            self.createFirework(xMovement: movementAmount, x: self.leftEdge, y: self.bottomEdge + 400)
            self.createFirework(xMovement: movementAmount, x: self.leftEdge, y: self.bottomEdge + 300)
            self.createFirework(xMovement: movementAmount, x: self.leftEdge, y: self.bottomEdge + 200)
            self.createFirework(xMovement: movementAmount, x: self.leftEdge, y: self.bottomEdge + 100)
            self.createFirework(xMovement: movementAmount, x: self.leftEdge, y: self.bottomEdge)
        case 3:
            self.createFirework(xMovement: -movementAmount, x: self.rightEdge, y: self.bottomEdge + 400)
            self.createFirework(xMovement: -movementAmount, x: self.rightEdge, y: self.bottomEdge + 300)
            self.createFirework(xMovement: -movementAmount, x: self.rightEdge, y: self.bottomEdge + 200)
            self.createFirework(xMovement: -movementAmount, x: self.rightEdge, y: self.bottomEdge + 100)
            self.createFirework(xMovement: -movementAmount, x: self.rightEdge, y: self.bottomEdge)
        default:
            break
        }
    }
    
    private func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = self.nodes(at: location)
        
        for node in nodesAtPoint {
            guard let sprite = node as? SKSpriteNode,
                sprite.name == "firework" else { continue }
            
            for parent in self.fireworks {
                let firework = parent.children[0] as! SKSpriteNode
                
                if firework.name == "selected" && firework.color != sprite.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            sprite.name = "selected"
            sprite.colorBlendFactor = 0
        }
    }
    
    private func update() {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                self.fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    private func explode(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        self.addChild(emitter)
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in self.fireworks.enumerated().reversed() {
            let firework = fireworkContainer.children[0] as! SKSpriteNode
            
            if firework.name == "selected" {
                self.explode(firework: fireworkContainer)
                self.fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            self.score += 200
        case 2:
            self.score += 500
        case 3:
            self.score += 1500
        case 4:
            self.score += 2500
        default:
            self.score += 4000
        }
    }
}
