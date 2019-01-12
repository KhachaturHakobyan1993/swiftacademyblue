//
//  Board.swift
//  Four in a Row
//
//  Created by Khachatur Hakobyan on 1/12/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import GameplayKit
import UIKit

enum ChipColor: Int {
    case none = 0
    case red
    case black
}

class Board: NSObject {
    static var width = 7
    static var height = 6
    var slots = [ChipColor]()
    var currentPlayer: Player

    
    override init() {
        self.currentPlayer = Player.allPlayers[0]
        for _ in 0..<Board.width * Board.height {
            self.slots.append(.none)
        }
        super.init()
    }
    
   
    // MARK: - Methods -
    
    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return self.slots[row + column * Board.height]
    }
    
    func set(chip: ChipColor, in column: Int, row: Int) {
        self.slots[row + column * Board.height] = chip
    }

    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            guard self.chip(inColumn: column, row: row) == .none else { continue }
            return row
        }
        return nil
    }
    
    func canMove(in column: Int) -> Bool {
        return self.nextEmptySlot(in: column) != nil
    }
    
    func add(chip: ChipColor, in column: Int) {
        guard let row = self.nextEmptySlot(in: column) else { return }
        self.set(chip: chip, in: column, row: row)
    }
    
    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            guard self.canMove(in: column) else { continue }
            return false
        }
        return true
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip
        
        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                if self.squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                } else if self.squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                } else if self.squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                } else if self.squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        // bail out early if we can't win from here
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        // still here? Check every square
        if self.chip(inColumn: col, row: row) != initialChip { return false }
        if self.chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if self.chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if self.chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
}


// MARK: - GKGameModel -

extension Board: GKGameModel {
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return self.currentPlayer
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            self.slots = board.slots
            self.currentPlayer = board.currentPlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let playerObject = player as? Player else { return nil }
        guard !self.isWin(for: playerObject) && !self.isWin(for: playerObject.opponent) else { return nil }
        
        var moves = [Move]()
        for column in 0 ..< Board.width {
            guard self.canMove(in: column) else { continue }
            moves.append(Move(column: column))
        }
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else { return }
        self.add(chip: currentPlayer.chip, in: move.column)
        self.currentPlayer = currentPlayer.opponent
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        guard let playerObject = player as? Player else { return 0 }
        if self.isWin(for: playerObject) {
            return 1000
        } else if self.isWin(for: playerObject.opponent) {
            return -1000
        }
        return 0
    }
}
