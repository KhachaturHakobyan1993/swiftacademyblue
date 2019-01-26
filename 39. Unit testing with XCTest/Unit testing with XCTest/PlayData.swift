//
//  PlsyData.swift
//  Unit testing with XCTest
//
//  Created by Khachatur Hakobyan on 1/26/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import Foundation

class PlayData {
    var allWords = [String]()
    var wordCounts: NSCountedSet!
    var filteredWords = [String]()
    
    init() {
        guard let path = Bundle.main.path(forResource: "plays", ofType: "txt"),
            let plays = try? String(contentsOfFile: path) else { return }
        self.allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
        self.allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
        self.allWords = self.allWords.filter{ $0 != ""}
        self.wordCounts = NSCountedSet(array: self.allWords)
        let sorted = self.wordCounts.allObjects.sorted {
            self.wordCounts.count(for: $0) > self.wordCounts.count(for: $1)
        }
        self.allWords = sorted as! [String]
        self.applyUserFilter("swift")
    }
    
    
    // MARK: - Methods -

    func applyUserFilter(_ input: String) {
        if let userNumber = Int(input) {
            self.applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
            self.applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
        self.filteredWords = self.allWords.filter(filter)
    }
}
