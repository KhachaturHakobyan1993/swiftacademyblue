//
//  GameScene.swift
//  Pachinko
//
//  Created by Khachatur Hakobyan on 12/22/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 { didSet { scoreLabel.text = "Score: \(score)" } }
    var editLabel: SKLabelNode!
    var editingMode: Bool = false { didSet { self.editLabel.text = self.editingMode ? "Done" :"Edit" } }
    
    
    override func didMove(to view: SKView) {
        self.setupSelfPhysicsBody()
        self.setupLabels()
        self.setupBackground()
        self.setupBouncers()
        self.setupSlots()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.updatEditingModeUI(touches)
    }
    
    
    // MARK: - Methods -
    
    func setupSelfPhysicsBody() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        self.addChild(background)
    }
    
    func setupLabels() {
        self.scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.horizontalAlignmentMode = .right
        self.scoreLabel.position = CGPoint(x: 980, y: 700)
        self.addChild(scoreLabel)
        
        self.editLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.editLabel.text = "Edit"
        self.editLabel.position = CGPoint(x: 80, y: 700)
        self.addChild(editLabel)
    }
    
    func setupBouncers() {
        self.makeBouncer(at: CGPoint(x: 0, y: 0))
        self.makeBouncer(at: CGPoint(x: 256, y: 0))
        self.makeBouncer(at: CGPoint(x: 512, y: 0))
        self.makeBouncer(at: CGPoint(x: 768, y: 0))
        self.makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    func setupSlots() {
        self.makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        self.makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        self.makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        self.makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    }
    
    func makeBouncer(at position: CGPoint)  {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.isDynamic = false
        self.addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase = (isGood ? SKSpriteNode(imageNamed: "slotBaseGood") :
        SKSpriteNode(imageNamed: "slotBaseBad"))
        let slotGlow = (isGood ? SKSpriteNode(imageNamed: "slotGlowGood") :
            SKSpriteNode(imageNamed: "slotGlowBad"))
        slotBase.name = (isGood ? "good" : "bad")
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        self.addChild(slotBase)
        self.addChild(slotGlow)
        let spin = SKAction.rotate(byAngle: .pi, duration: 5)
        let reverse = SKAction.reversed(spin)()
        let sequence = SKAction.sequence([spin, reverse])
        let spinForever = SKAction.repeatForever(sequence)
        slotGlow.run(spinForever)
    }
    
    func addBall(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 1: Example Box.
        //let box = SKSpriteNode(color: UIColor.red, size: CGSize(width: 64, height: 64))
        //box.position = location
        //box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        //self.addChild(box)
        
        // 2: Example Ball.
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.position = location
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.restitution = 0.4
        ball.name = "ball"
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        self.addChild(ball)
    }
    
    func addBox(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let size = CGSize(width: Int.random(in: 16...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        self.addChild(box)
    }
    
    func updatEditingModeUI(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = self.nodes(at: location)

        guard !objects.contains(editLabel) else {
            self.editingMode = !self.editingMode
            return
        }
        self.editingMode ? self.addBox(touches) :
        self.addBall(touches)
    }
    
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            self.destroy(ball: ball)
            self.score += 1
        } else if object.name == "bad" {
            self.destroy(ball: ball)
            self.score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            self.addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    
    // MARK: - SKPhysicsContactDelegate -

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            self.collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            self.collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
