//
//  Move.swift
//  Four in a Row
//
//  Created by Khachatur Hakobyan on 1/12/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import GameplayKit
import UIKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int
    
    
    init(column: Int) {
        self.column = column
    }
}
