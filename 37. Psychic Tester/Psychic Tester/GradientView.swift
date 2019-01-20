//
//  GradientView.swift
//  Psychic Tester
//
//  Created by Khachatur Hakobyan on 1/20/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (self.layer as! CAGradientLayer).colors = [self.topColor.cgColor, self.bottomColor.cgColor]
    }
}
