//
//  ViewController.swift
//  Four in a Row
//
//  Created by Khachatur Hakobyan on 1/12/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import GameplayKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var columnButtons: [UIButton]!
    var placedChips = [[UIView]]()
    var board: Board!
    var strategist: GKMinmaxStrategist!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resetPlacedChips()
        self.setupStrategy()
        self.resetBoard()
    }
    
    
    // MARK: - Methods Setup -
    
    private func resetPlacedChips() {
        for _ in 0..<Board.width {
            self.placedChips.append([UIView]())
        }
    }
    
    private func setupStrategy() {
        self.strategist = GKMinmaxStrategist()
        self.strategist.maxLookAheadDepth = 7
        self.strategist.randomSource = GKARC4RandomSource()
    }
    
    private func resetBoard() {
        self.board = Board()
        self.strategist.gameModel = self.board
        self.updateUI()
        for i in 0..<self.placedChips.count {
            for chip in self.placedChips[i] {
                chip.removeFromSuperview()
            }
            self.placedChips[i].removeAll(keepingCapacity: true)
        }

    }
    
    
    // MARK: - Methods -
    
    private func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = self.columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        guard self.placedChips[column].count < row + 1 else { return }
        let newChip = UIView()
        newChip.frame = rect
        newChip.isUserInteractionEnabled = false
        newChip.backgroundColor = color
        newChip.layer.cornerRadius = size / 2
        newChip.center = positionForChip(inColumn: column, row: row)
        newChip.transform = CGAffineTransform(translationX: 0, y: -800)
        self.view.addSubview(newChip)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            newChip.transform = CGAffineTransform.identity
        })
        
        self.placedChips[column].append(newChip)
    }
    
    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let button = self.columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        
        let xOffset = button.frame.midX
        var yOffset = button.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func updateUI() {
        self.title = "\(self.board.currentPlayer.name)'s Turn"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.board.currentPlayer.color]
        guard self.board.currentPlayer.chip == .black else { return }
        self.startAIMove()
    }
    
    func continueGame() {
        var gameOverTitle: String? = nil
        
        if self.board.isWin(for: self.board.activePlayer!) {
            gameOverTitle = "\(self.board.currentPlayer.name) Wins!"
        } else if self.board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            return
        }
        
        self.board.currentPlayer = board.currentPlayer.opponent
        self.updateUI()
    }
    
    func startAIMove() {
        self.columnButtons.forEach { $0.isEnabled = false }
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }
    
    func columnForAIMove() -> Int? {
        guard let aiMove = self.strategist.bestMove(for: board.currentPlayer) as? Move else { return nil }
        return aiMove.column
    }
    
    func makeAIMove(in column: Int) {
        self.columnButtons.forEach { $0.isEnabled = true }
        self.navigationItem.leftBarButtonItem = nil
        
        if let row = self.board.nextEmptySlot(in: column) {
            self.board.add(chip: board.currentPlayer.chip, in: column)
            self.addChip(inColumn: column, row:row, color: board.currentPlayer.color)
            self.continueGame()
        }
    }
    
    
    // MARK: - IBActions -
    
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        guard let row = self.board.nextEmptySlot(in: column) else { return }
        self.board.add(chip: self.board.currentPlayer.chip, in: column)
        self.addChip(inColumn: column, row: row, color: self.board.currentPlayer.color)
        self.continueGame()
    }
}

