//
//  Unit_testing_with_XCTestTests.swift
//  Unit testing with XCTestTests
//
//  Created by Khachatur Hakobyan on 1/26/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import XCTest
@testable import Unit_testing_with_XCTest

class Unit_testing_with_XCTestTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    
    // MARK: - Methods -
    
    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "home"), 174, "Home does not appear 174 times")
        XCTAssertEqual(playData.wordCounts.count(for: "fun"), 4, "Fun does not appear 4 times")
        XCTAssertEqual(playData.wordCounts.count(for: "mortal"), 41, "Mortal does not appear 41 times")
    }
    
    
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495)
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55)
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1)
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56)
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7)
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0)
    }

    
    func testWordsLoadQuickly() {
        measure {
            _ = PlayData()
        }
    }
    
    

}
