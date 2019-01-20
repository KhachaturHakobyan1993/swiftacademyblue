//
//  ViewController.swift
//  Psychic Tester
//
//  Created by Khachatur Hakobyan on 1/20/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import WatchConnectivity
import AVFoundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var cardContainer: UIView!
    var allCards = [CardViewController]()
    var music: AVAudioPlayer!
    var lastMessage: CFAbsoluteTime = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkWCSession()
        self.animateBackground()
        self.createParticles()
        self.loadCards()
        self.playMusic()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showAlertForWatch()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self.cardContainer)
        
        for (index, card) in self.allCards.enumerated() {
            if card.view.frame.contains(location) {
                if self.view.traitCollection.forceTouchCapability == .available {
                    if touch.force == touch.maximumPossibleForce {
                        card.frontImageView.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    } else {
                        card.frontImageView.image = UIImage(named: "cardBack")
                        card.isCorrect = false
                    }
                }
            }
            
            if card.isCorrect {
                self.sendWatchMessage(index: index + 1)
            }
        }
    }
    
    
    // MARK: - Methods Setup -

    private func checkWCSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    func animateBackground() {
        self.view.backgroundColor = UIColor.red
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
    }
    
    func playMusic() {
        guard let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3"),
            let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) else { return }
        self.music = audioPlayer
        self.music.numberOfLoops = -1
        self.music.play()
    }
    
    @objc func loadCards() {
        for card in self.allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }
        self.allCards.removeAll(keepingCapacity: true)
        
        // create an array of card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        // load and unwrap our Zener card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        // create an array of the images, one for each card, then shuffle it
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        for (index, position) in positions.enumerated() {
            // loop over each card position and create a new card view controller
            let cardVC = CardViewController()
            cardVC.delegate = self
            
            // use view controller containment and also add the card's view to our cardContainer view
            self.addChild(cardVC)
            self.cardContainer.addSubview(cardVC.view)
            cardVC.didMove(toParent: self)
            
            // position the card appropriately, then give it an image from our array
            cardVC.view.center = position
            cardVC.frontImageView.image = images[index]
            
            // if we just gave the new card the star image, mark this as the correct answer
            if cardVC.frontImageView.image == star {
                cardVC.isCorrect = true
            }
            
            // add the new card view controller to our array for easier tracking
            self.allCards.append(cardVC)
        }
        self.view.isUserInteractionEnabled = true
    }
    
    
    // MARK: - Methods -
    
    func cardTapped(_ tapped: CardViewController) {
        guard self.view.isUserInteractionEnabled == true else { return }
        self.view.isUserInteractionEnabled = false
        
        for card in self.allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }
        
        self.perform(#selector(ViewController.loadCards), with: nil, afterDelay: 2)
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: self.view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: self.view.frame.width, height: 5)
        particleEmitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        self.gradientView.layer.addSublayer(particleEmitter)
    }
    
    func sendWatchMessage(index: Int) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        // if less than half a second has passed, bail out
        if self.lastMessage + 0.5 > currentTime {
            return
        }
        
        // send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes
            let message = ["Message": index.description]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        
        // update our rate limiting property
        self.lastMessage = CFAbsoluteTimeGetCurrent()
    }
    
    func showAlertForWatch() {
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake For 70 Seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. You're done!"
        let alertVC = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I'm Ready", style: .default))
        self.present(alertVC, animated: true)
    }
}


// MARK: - WCSessionDelegate -

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint(#function)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint(#function)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint(#function)
    }
}
