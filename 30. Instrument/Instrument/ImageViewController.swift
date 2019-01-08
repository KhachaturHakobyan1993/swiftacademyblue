//
//  ImageViewController.swift
//  Instrument
//
//  Created by Khachatur Hakobyan on 1/8/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var animTimer: Timer!
    var imageName: String!
    var owner: SelectionViewController!
    
    
    
    override func loadView() {
        super.loadView()
        self.creatImageViewAndTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateImageView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.animTimer.invalidate()
    }
    
    
    // MARK: - Methods Setup -

    private func creatImageViewAndTimer() {
        self.view.backgroundColor = UIColor.black
        
        // create an image view that fills the screen
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.alpha = 0
        self.view.addSubview(self.imageView)
        
        // make the image view fill the screen
        self.imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // schedule an animation that does something vaguely interesting
        self.animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            // do something exciting with our image
            self.imageView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 3) {
                self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }
    
    private func setupImage() {
        self.title = self.imageName.replacingOccurrences(of: "-Large.jpg", with: "")
        let original = UIImage(named: self.imageName)!
        
        let renderer = UIGraphicsImageRenderer(size: original.size)
        
        let rounded = renderer.image { context in
            context.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
            context.cgContext.clip()
            context.cgContext.closePath()

            original.draw(at: CGPoint.zero)
        }
        
        self.imageView.image = rounded
    }
    
    
    // MARK: - Methods Touches Handler -
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.toches()
    }
    
    
    // MARK: - Methods -
    
    private func animateImageView() {
        self.imageView.alpha = 0
        UIView.animate(withDuration: 3) { [unowned self] in
            self.imageView.alpha = 1
        }
    }
    
    private func toches() {
        var currentVal = UserDefaults.standard.integer(forKey: self.imageName)
        currentVal += 1
        UserDefaults.standard.set(currentVal, forKey: self.imageName)
        
        // tell the parent view controller that it should refresh its table counters when we go back
        self.owner.dirty = true
    }
}
