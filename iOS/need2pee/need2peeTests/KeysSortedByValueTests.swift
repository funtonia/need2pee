//
//  KeysSortedByValueTests.swift
//  need2pee
//
//  Created by Schlaue Füchse on 29.04.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import XCTest
@testable import need2pee

class KeysSortedByValueTests: XCTestCase {
    
    var namesDistances = [String: Int]()
    let sortedNamesResult : [String] = ["toilet2", "toilet5", "toilet3", "toilet4", "toilet7", "toilet6", "toilet1"]
    
    //This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        namesDistances["toilet1"] = 7
        namesDistances["toilet2"] = 1
        namesDistances["toilet3"] = 3
        namesDistances["toilet4"] = 4
        namesDistances["toilet5"] = 2
        namesDistances["toilet6"] = 6
        namesDistances["toilet7"] = 5
    }
    
    //This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    //Tests the keysSortedByValue() function
    func testKeysSortedByValue() {
        let sortedNames : [String] = Model.model.keysSortedByValue(namesDistances)
        XCTAssertEqual(sortedNames, sortedNamesResult, "The function keysSortedByValue() doesn't work like expected. The ResultArray should look like this: ['toilet2', 'toilet5', 'toilet3', 'toilet4', 'toilet7', 'toilet6', 'toilet1']")
    }
    
}
