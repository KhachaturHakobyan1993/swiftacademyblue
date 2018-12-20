//
//  ViewController.swift
//  7 Swifty Words
//
//  Created by Khachatur Hakobyan on 12/19/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var cluesLabel: UILabel!
    @IBOutlet var answersLabel: UILabel!
    @IBOutlet var currentAnswerTextField: UITextField!
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var score = 0 { didSet { self.scoreLabel.text = "Score: \(self.score)" }}
    var level = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLetterButtons()
        self.loadLevel()
    }
    
    // MARK: - Methods -
    
    func setupLetterButtons() {
        for subview in self.view.subviews where subview.tag == 1001 {
            let button = subview as! UIButton
            self.letterButtons.append(button)
            button.addTarget(self, action: #selector(ViewController.letterButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        guard let levelFilePath = Bundle.main.path(forResource: "level\(self.level)", ofType: "txt"),
            let levelContent = try? String(contentsOfFile: levelFilePath) else { return }
        var lines = levelContent.components(separatedBy: "\n")
        lines.shuffle()
        
        for (index, line) in lines.enumerated() {
            let parts = line.components(separatedBy: ":")
            let answer = parts[0]
            let clue = parts[1]
            
            clueString += "\(index + 1). \(clue)\n"
            
            let solutionWord = answer.replacingOccurrences(of: "|", with: "")
            solutionString += "\(solutionWord.count) letters\n"
            self.solutions.append(solutionWord)
            
            let bits = answer.components(separatedBy: "|")
            letterBits += bits
        }
        
        self.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits.shuffle()
        
        if letterBits.count == self.letterButtons.count {
            for index in 0..<self.letterButtons.count {
                self.letterButtons[index].setTitle(letterBits[index], for: .normal)
            }
        }
    }
    
    func showAlertForNextLevel() {
        let alertVC = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: self.levelUp))
        self.present(alertVC, animated: true)
    }
    
    func levelUp(action: UIAlertAction) {
        self.level += 1
        self.solutions.removeAll(keepingCapacity: true)
        self.loadLevel()
        self.letterButtons.forEach({ $0.isHidden = false })
    }
    
    
    // MARK: - IBActions -
    
    @IBAction func submiteButtonTapped(_ sender: UIButton) {
        guard let currentAnswer = self.currentAnswerTextField.text,
            let index = self.solutions.index(of: currentAnswer),
            var answers = self.answersLabel.text?.components(separatedBy: "\n")else { return }
        answers[index] = currentAnswer
        self.answersLabel.text = answers.joined(separator: "\n")
        self.currentAnswerTextField.text = ""
        self.activatedButtons.removeAll()
        self.score += 1
        guard self.score == 7 else { return }
        self.showAlertForNextLevel()
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        self.currentAnswerTextField.text = ""
        self.activatedButtons.forEach({ $0.isHidden = false })
        self.activatedButtons.removeAll()
    }
    
    @objc func letterButtonTapped(_ sender: UIButton) {
        self.currentAnswerTextField.text! += sender.title(for: .normal)!
        self.activatedButtons.append(sender)
        sender.isHidden = true
    }
}
