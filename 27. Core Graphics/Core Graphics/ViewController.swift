//
//  ViewController.swift
//  Core Graphics
//
//  Created by Khachatur Hakobyan on 1/6/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

enum DrawType: UInt8 {
    case rectangle = 0
    case circle = 1
    case checkerboard = 2
    case squares = 3
    case lines = 4
    case imageText = 5
    case triangle = 6
    
    mutating func next() {
        let value = self.rawValue + 1
        guard let newDrawType = DrawType(rawValue: value) else { self = .rectangle; return }
        self = newDrawType
    }
}

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = DrawType.rectangle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawRectangle()
    }
    

    // MARK: - Methods Setup -

    
    
    // MARK: - Methods -
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { (context) in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        self.imageView.image = imgRendered
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { (context) in
            let rectangle = CGRect(x: 5, y: 5, width: 502, height: 502)
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        self.imageView.image = imgRendered
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        context.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        self.imageView.image = imgRendered
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        self.imageView.image = imgRendered
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                context.cgContext.rotate(by: CGFloat.pi / 2)
                
                if first {
                    context.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        self.imageView.image = imgRendered
    }
    
    func drawTriangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { context in
            let size = CGSize(width: 512, height: 512)
            let pointA = CGPoint(x: size.width - 100, y: size.height + 10)
            let pointB = CGPoint(x: size.width, y: size.height)
            let pointC = CGPoint(x: size.width, y: size.height - 100)
            context.cgContext.move(to: pointA)
            context.cgContext.addLine(to: pointB)
            context.cgContext.addLine(to: pointC)
            context.cgContext.addLine(to: pointA)
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fillPath()
        }
        self.imageView.image = imgRendered
    }
    
    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let imgRendered = renderer.image { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 36)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            string.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        self.imageView.image = imgRendered
    }
    
    // MARK: - IBActions -
    
    @IBAction func buttonRedrawTapped(_ sender: UIButton) {
        self.currentDrawType.next()
        
        switch self.currentDrawType {
        case .rectangle:
            self.drawRectangle()
        case .circle:
            self.drawCircle()
        case .checkerboard:
            self.drawCheckerboard()
        case .squares:
            self.drawRotatedSquares()
        case .lines:
            self.drawLines()
        case .imageText:
            self.drawImagesAndText()
        case .triangle:
            self.drawTriangle()
        }
    }
}

