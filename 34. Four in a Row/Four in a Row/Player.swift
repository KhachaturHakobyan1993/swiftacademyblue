//
//  Player.swift
//  Four in a Row
//
//  Created by Khachatur Hakobyan on 1/12/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import GameplayKit
import UIKit

class Player: NSObject {
    var chip: ChipColor
    var color: UIColor
    var name: String
    var opponent: Player {
        return self.chip == .red ? Player.allPlayers[1] : Player.allPlayers[0]
    }
    
    static var allPlayers = [Player(chip: .red), Player(chip: .black)]
    
    init(chip: ChipColor) {
        self.chip = chip
        self.color = chip == .red ? .red : .black
        self.name = chip == .red ? "Red" : "Black"
        super.init()
    }
}


// MARK: - GKGameModelPlayer -

extension Player: GKGameModelPlayer {
    var playerId: Int {
        return self.chip.rawValue
    }
}
