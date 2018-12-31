//
//  WhackSlot.swift
//  Whack-a-Penguin
//
//  Created by Khachatur Hakobyan on 12/31/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    
    // MARK: - Methods -
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        self.addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        //cropNode.maskNode = nil
        
        self.charNode = SKSpriteNode(imageNamed: "penguinGood")
        self.charNode.position = CGPoint(x: 0, y: -90)
        self.charNode.name = "character"
        self.charNode.zPosition = 0
        cropNode.addChild(self.charNode)
        
        self.addChild(cropNode)
    }
    
    fileprivate enum PenguinType: Int {
        case good
        case bad
        case bad1
    }
    
    func show(hideTime: Double) {
        if self.isVisible { return }
        self.charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        self.isVisible = true
        self.isHit = false
        
        let type = PenguinType(rawValue: Int.random(in: 0...2))!
        self.charNode.texture = type == .good ? SKTexture(imageNamed: "penguinGood") :
            SKTexture(imageNamed: "penguinEvil")
        self.charNode.name = type == .good ? "charFriend" : "charEnemy"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [unowned self] in
            self.hide()
        }
    }
    
    func hide() {
        if !self.isVisible { return }
        
        self.charNode.run(SKAction.moveBy(x: 0, y:-80, duration:0.05))
        self.isVisible = false
    }
    
    func hit() {
        self.isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y:-80, duration:0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        self.charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
}

