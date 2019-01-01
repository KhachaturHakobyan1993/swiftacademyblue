//
//  GameScene.swift
//  Swifty Ninja
//
//  Created by Khachatur Hakobyan on 1/1/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum ForceBomb {
    case never, always, random
}


enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}


class GameScene: SKScene {
    var gameScore: SKLabelNode!
    var score = 0 { didSet { self.gameScore.text = "Score: \(self.score)" } }
    var livesImages = [SKSpriteNode]()
    var lives = 3
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer!
    var gameEnded = false
    var popupTime = 0.9
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true

    
    override func didMove(to view: SKView) {
        self.setup()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.update()
    }
    

    // MARK: - Methods Touch Handling -

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeSlicePoints.removeAll(keepingCapacity: true)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.activeSlicePoints.append(location)
        self.redrawActiveSlice()
        self.activeSliceBG.removeAllActions()
        self.activeSliceFG.removeAllActions()
        self.activeSliceBG.alpha = 1
        self.activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.gameEnded,
            let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.activeSlicePoints.append(location)
        self.redrawActiveSlice()
        if !self.isSwooshSoundActive  {
            self.playSwooshSound()
        }
        self.checkCollision(location: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        self.activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    
    // MARK: - Methods Setup -
    
    private func setup() {
        self.setupBackgroundToo()
        self.createScore()
        self.createLives()
        self.createSlices()
        self.lauchEnenmies()
    }
    
    private func setupBackgroundToo() {
        let backgorund = SKSpriteNode(imageNamed: "sliceBackground")
        backgorund.position = CGPoint(x: self.scene!.frame.midX, y: self.scene!.frame.midY)
        backgorund.blendMode = .replace
        backgorund.zPosition = -1
        self.addChild(backgorund)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        self.physicsWorld.speed = 0.85
    }
    
    private func createScore() {
        self.gameScore = SKLabelNode(fontNamed: "Chalkduster")
        self.gameScore.text = "Score: 0"
        self.gameScore.horizontalAlignmentMode = .left
        self.gameScore.fontSize = 48
        self.gameScore.position = CGPoint(x: 8, y: 8)
        self.addChild(self.gameScore)
    }
    
    private func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: 834 + (i * 70), y: 720)
            self.addChild(spriteNode)
            self.livesImages.append(spriteNode)
        }
    }
    
    private func createSlices() {
        self.activeSliceBG = SKShapeNode()
        self.activeSliceBG.zPosition = 2
        self.activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        self.activeSliceBG.lineWidth = 9
        self.addChild(self.activeSliceBG)
        
        self.activeSliceFG = SKShapeNode()
        self.activeSliceFG.zPosition = 2
        self.activeSliceFG.strokeColor = UIColor.white
        self.activeSliceFG.lineWidth = 5
        self.addChild(self.activeSliceFG)
    }
    
    private func lauchEnenmies() {
        self.sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType.allCases.randomElement()!
            self.sequence.append(nextSequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.tossEnemies()
        }
    }
    
    
    // MARK: - Methods -

    private func redrawActiveSlice() {
        guard self.activeSlicePoints.count >= 2 else {
            self.activeSliceBG.path = nil
            self.activeSliceFG.path = nil
            return
        }
        
        while self.activeSlicePoints.count > 12 {
            self.activeSlicePoints.remove(at: 0)
        }
        
        let path = UIBezierPath()
        path.move(to: self.activeSlicePoints[0])
        
        for i in 1..<self.activeSlicePoints.count {
            path.addLine(to: self.activeSlicePoints[i])
        }
        
        self.activeSliceBG.path = path.cgPath
        self.activeSliceFG.path = path.cgPath
    }
    
    private func playSwooshSound() {
        self.isSwooshSoundActive = true
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        let swooshSoundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(swooshSoundAction) {
            self.isSwooshSoundActive = false
        }
    }
    
    private func createEnemy(forceBomb: ForceBomb = .random) {
        var enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            // 1
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            // 3
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            // 4
            let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType:nil)!
            let url = URL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()
            
            // 5
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // 1
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        // 2
        let randomAngularVelocity = CGFloat.random(in: -6...6) / 2.0
        var randomXVelocity = 0
        
        // 3
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        
        // 4
        let randomYVelocity = Int.random(in: 24...32)
        
        // 5
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemy)
        self.activeEnemies.append(enemy)
    }
    
    private func tossEnemies() {
        guard !self.gameEnded else { return }
        
        self.popupTime *= 0.991
        self.chainDelay *= 0.99
        self.physicsWorld.speed *= 1.02
        
        let sequenceType = self.sequence[self.sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            self.createEnemy(forceBomb: .never)
        case .one:
            self.createEnemy()
        case .twoWithOneBomb:
            self.createEnemy(forceBomb: .never)
            self.createEnemy(forceBomb: .always)
        case .two:
            self.createEnemy()
            self.createEnemy()
        case .three:
            self.createEnemy()
            self.createEnemy()
            self.createEnemy()
        case .four:
            self.createEnemy()
            self.createEnemy()
            self.createEnemy()
            self.createEnemy()
        case .chain:
            self.createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 5.0)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 5.0 * 2)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 5.0 * 3)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 5.0 * 4)) { [unowned self] in self.createEnemy() }
        case .fastChain:
            self.createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 10.0)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 10.0 * 2)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 10.0 * 3)) { [unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.chainDelay / 10.0 * 4)) { [unowned self] in self.createEnemy() }
        }
        
        self.sequencePosition += 1
        self.nextSequenceQueued = false
    }
    
    private func update() {
        if self.activeEnemies.count > 0 {
            for node in self.activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        self.subtractLife()
                        
                        node.removeFromParent()
                        
                        if let index = self.activeEnemies.index(of: node) {
                            self.activeEnemies.remove(at: index)
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        
                        if let index = self.activeEnemies.index(of: node) {
                            self.activeEnemies.remove(at: index)
                        }
                    }
                }
            }
        } else {
            if !self.nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [unowned self] in
                    self.tossEnemies()
                }
                self.nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in self.activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs – stop the fuse sound!
            if self.bombSoundEffect != nil {
                self.bombSoundEffect.stop()
                self.bombSoundEffect = nil
            }
        }
    }
    
    private func subtractLife() {
        self.lives -= 1
        self.run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if self.lives == 2 {
            life = self.livesImages[0]
        } else if self.lives == 1 {
            life = self.livesImages[1]
        } else {
            life = self.livesImages[2]
            self.endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    private func endGame(triggeredByBomb: Bool) {
        guard !self.gameEnded else { return }
        self.gameEnded = true
        self.physicsWorld.speed = 0
        self.isUserInteractionEnabled = false
        
        if self.bombSoundEffect != nil {
            self.bombSoundEffect.stop()
            self.bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            self.livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            self.livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            self.livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
    private func checkCollision(location: CGPoint) {
        let nodesAtPoint = self.nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "enemy" {
                // destroy penguin
                // 1
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                self.addChild(emitter)
                
                // 2
                node.name = ""
                
                // 3
                node.physicsBody?.isDynamic = false
                
                // 4
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)
                
                // 6
                self.score += 1
                
                // 7
                let index = self.activeEnemies.index(of: node as! SKSpriteNode)!
                self.activeEnemies.remove(at: index)
                
                // 8
                self.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                // destroy bomb
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                self.addChild(emitter)
                
                node.name = ""
                node.parent?.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.parent?.run(seq)
                
                let index = self.activeEnemies.index(of: node.parent as! SKSpriteNode)!
                self.activeEnemies.remove(at: index)
                
                self.run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                self.endGame(triggeredByBomb: true)
            }
        }
    }
}
