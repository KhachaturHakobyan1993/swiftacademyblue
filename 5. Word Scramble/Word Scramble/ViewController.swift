//
//  ViewController.swift
//  Word Scramble
//
//  Created by Khachatur Hakobyan on 12/18/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.fethAllWords()
        self.startGame()
    }

    
    // MARK: - Methods -
    
    func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.promptForAnswer))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.startGame))
    }
    
    func fethAllWords() {
        guard let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt"),
            let startWords = try? String(contentsOfFile: startWordsPath) else { self.allWords = ["silkworm"] ;return }
        self.allWords = startWords.components(separatedBy: "\n")
    }
    
    @objc func startGame() {
        self.title = self.allWords.randomElement()
        self.usedWords.removeAll(keepingCapacity: true)
        self.tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let alertVC = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        alertVC.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, alertVC](action) in
            let answer = alertVC.textFields![0]
            self.submit(answer: answer.text!)
        }
        alertVC.addAction(submitAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()

        guard self.isPossible(word: lowerAnswer) else {
            self.showAlert(errorTitle: "Word not possible",
                           errorMessage: "You can't spell that word from '\(self.title!.lowercased())'!")
            return
        }
        guard self.isOriginal(word: lowerAnswer) else {
            self.showAlert(errorTitle: "Word used already",
                           errorMessage: "Be more original!")
            return
        }
        guard self.isReal(word: lowerAnswer) else {
            self.showAlert(errorTitle: "Word not recognised",
                           errorMessage: "You can't just make them up, you know!")
            return
        }
        
        self.usedWords.insert(answer, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = self.title!.lowercased()
        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !self.usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func showAlert(errorTitle: String, errorMessage: String) {
        let alertVC = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = self.usedWords[indexPath.row]
        return cell
    }
}

