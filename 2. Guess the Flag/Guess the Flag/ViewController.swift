//
//  ViewController.swift
//  Storm Viewer
//
//  Created by Khachatur Hakobyan on 12/16/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    var countries = [String]()
    var score = 0
    var correctAnswer = Int.random(in: 0...2)


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.askQuestion()
    }


    // MARK: - Methods -
    
    func setup() {
        self.countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        self.button1.layer.borderWidth = 1
        self.button1.layer.borderColor = UIColor.lightGray.cgColor
        self.button2.layer.borderWidth = 1
        self.button2.layer.borderColor = UIColor.lightGray.cgColor
        self.button3.layer.borderWidth = 1
        self.button3.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func askQuestion(_ action: UIAlertAction? = nil) {
        self.countries.shuffle()
        self.correctAnswer = Int.random(in: 0...2)
        self.title = self.countries[self.correctAnswer].uppercased()
        self.button1.setImage(UIImage(named: self.countries[0]), for: .normal)
        self.button2.setImage(UIImage(named: self.countries[1]), for: .normal)
        self.button3.setImage(UIImage(named: self.countries[2]), for: .normal)
    }
    
    func showAlertScore(tappedButton: UIButton) {
        self.score += (self.correctAnswer == tappedButton.tag ? 1 : -1)
        let title = (self.correctAnswer == tappedButton.tag ? "Correct" : "Wrong")
        let alertVC = UIAlertController(title: title, message: "Your score is \(self.score)", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: self.askQuestion)
        alertVC.addAction(continueAction)
        self.present(alertVC, animated: true, completion: nil)
    }

    
    // MARK: - IBActions -

    @IBAction func buttonTapped(_ sender: UIButton) {
        self.showAlertScore(tappedButton: sender)
    }
}

