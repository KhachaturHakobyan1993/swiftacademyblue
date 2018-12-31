//
//  ViewController.swift
//  Animation
//
//  Created by Khachatur Hakobyan on 12/31/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tapButton: UIButton!
    var imageView: UIImageView!
    var currentAnimation = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageView.updateCenter(rect: self.view.safeAreaLayoutGuide.layoutFrame)
    }
    
    
    // MARK: - Methods -
    
    private func setup() {
        self.imageView = UIImageView(image: UIImage(named: "penguin"))
        self.imageView.updateCenter(rect: self.view.safeAreaLayoutGuide.layoutFrame)
        self.view.addSubview(self.imageView)
    }

    
    // MARK: - IBActions -
    
    @IBAction func tapButtonTapped(_ sender: UIButton) {
        self.tapButton.isHidden = true
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: {  [unowned self] in
                        switch self.currentAnimation {
                        case 0:
                            self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                        case 1:
                            self.imageView.transform = CGAffineTransform.identity
                        case 2:
                            self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                        case 3:
                            self.imageView.transform = CGAffineTransform.identity
                        case 4:
                            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                        case 5:
                            self.imageView.transform = CGAffineTransform.identity
                        case 6:
                            self.imageView.alpha = 0.1
                            self.imageView.backgroundColor = UIColor.green
                        case 7:
                            self.imageView.alpha = 1
                            self.imageView.backgroundColor = UIColor.clear
                        default:break
                            
                        }
        }) { [unowned self] (finished) in
            self.tapButton.isHidden = false
        }

        self.currentAnimation += 1
        if self.currentAnimation > 7 { self.currentAnimation = 0 }
    }
}


// MARK: - UIImageView -

extension UIImageView {
    func updateCenter(rect: CGRect) {
        self.center = CGPoint(x: rect.midX, y: rect.midY)
    }
}
