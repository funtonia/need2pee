//
//  UniquenessTests.swift
//  need2pee
//
//  Created by Schlaue Füchse on 29.04.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import XCTest
@testable import need2pee

class UniquenessTests: XCTestCase {
    
    //This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    //This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    //Tests the testUniqueness() function
    func testUniqunessTrue(){
        XCTAssertTrue(Model.model.testUniqueness("xyzDieseToilette"))
        XCTAssertTrue(Model.model.testUniqueness("blayyyyyy"))
        XCTAssertTrue(Model.model.testUniqueness("Wilhelmsplatz     "))
    }
    
    //Tests the testUniqueness() function
    func testUniqunessFalse(){
        XCTAssertFalse(Model.model.testUniqueness("Charlottenplatz 10"), "This test may fail due to the fakt that the toilet has been deleted")
        XCTAssertFalse(Model.model.testUniqueness("Schlossplatz, U-Bahn"), "This test may fail due to the fakt that the toilet has been deleted")
        XCTAssertFalse(Model.model.testUniqueness("Paulinenbrücke"), "This test may fail due to the fakt that the toilet has been deleted")
    }
}
