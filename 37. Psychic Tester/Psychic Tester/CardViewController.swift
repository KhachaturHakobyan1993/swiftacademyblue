//
//  CardViewController.swift
//  Psychic Tester
//
//  Created by Khachatur Hakobyan on 1/20/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    var frontImageView: UIImageView!
    var backImageView: UIImageView!
    var isCorrect = false
    weak var delegate: ViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageViews()
        self.setupTapGesture()
        self.perform(#selector(CardViewController.wiggle), with: nil, afterDelay: 1)
    }
    
    
    // MARK: - Methods Setup -

    private func setupImageViews() {
        self.view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        self.frontImageView = UIImageView(image: UIImage(named: "cardBack"))
        self.backImageView = UIImageView(image: UIImage(named: "cardBack"))
        self.view.addSubview(self.frontImageView)
        self.view.addSubview(self.backImageView)
        self.frontImageView.isHidden = true
        self.backImageView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.backImageView.alpha = 1
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardViewController.cardTapped))
        self.backImageView.isUserInteractionEnabled = true
        self.backImageView.addGestureRecognizer(tap)
    }
    
    
    // MARK: - Methods -
    
    @objc func cardTapped() {
        self.delegate.cardTapped(self)
    }
    
    @objc func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    func wasTapped() {
        UIView.transition(with: self.view, duration: 0.7, options: [.transitionFlipFromRight], animations: { [unowned self] in
            self.backImageView.isHidden = true
            self.frontImageView.isHidden = false
        })
    }
    
    @objc func wiggle() {
        if Int.random(in: 0...3) == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
                self.backImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                self.backImageView.transform = CGAffineTransform.identity
            }
            self.perform(#selector(CardViewController.wiggle), with: nil, afterDelay: 8)
        } else {
            self.perform(#selector(CardViewController.wiggle), with: nil, afterDelay: 2)
        }
    }
}
