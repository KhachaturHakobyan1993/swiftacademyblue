//
//  BuildingNode.swift
//  Exploding Monkeys
//
//  Created by Khachatur Hakobyan on 1/7/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
    
    
    // MARK: - Methods Setup -

    func setup() {
        self.name = "building"
        self.currentImage = self.drawBuilding(size: self.size)
        self.texture = SKTexture(image: self.currentImage)
        self.configurePhysics()
    }
    
    private func configurePhysics() {
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    private func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let imgRendered = renderer.image { (context) in
            let rectangle = CGRect(origin: .zero, size: size)
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fill)
            
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        context.cgContext.setFillColor(lightOnColor.cgColor)
                    } else {
                        context.cgContext.setFillColor(lightOffColor.cgColor)
                    }
                    
                    let rect = CGRect(x: col, y: row, width: 15, height: 20)
                    context.cgContext.fill(rect)
                }
            }
            
        }
        return imgRendered
    }
    
    
    // MARK: - Methods -
    
    func hitAt(point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let imgRendered = renderer.image { context in
            self.currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            context.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            context.cgContext.setBlendMode(.clear)
            context.cgContext.drawPath(using: .fill)
        }
        
        self.texture = SKTexture(image: imgRendered)
        self.currentImage = imgRendered
        
        self.configurePhysics()
    }
}
