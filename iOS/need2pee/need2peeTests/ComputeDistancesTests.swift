//
//  ComputeDistancesTests.swift
//  need2pee
//
//  Created by Schlaue Füchse on 29.04.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import XCTest
@testable import need2pee

class ComputeDistancesTests: XCTestCase {
    
    //This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    //This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    //Testing the function ComputeDistances()
    func testComputeDistances() {
        let computedDistances : [String : Int] = Model.model.computeDistances(48.7667, ownLocationLongitude: 9.1833)
        XCTAssertNotNil(computedDistances, "Function ComputeDistances() failed")
        
        let free : Bool = Model.model.free
        let barrierFree : Bool = Model.model.barrierFree
        
        //If the filter free and barrierFree are true the computed distances between the own location and "Am Neckator" / "Rotebühlplatz(LBBW)" will be checked
        if (free && barrierFree) {
            for toilet in computedDistances {
                if toilet.0 == "Am Neckartor" {
                    XCTAssertEqual(toilet.1, 2207, "Distance between specified location and the toilet's location is not like expected. Distance should be 2207")
                }
                if toilet.0 == "Rotebühlplatz(LBBW)" {
                    XCTAssertEqual(toilet.1, 1018, "Distance between specified location and the toilet's location is not like expected. Distance should be 2207")
                }
                
            }
        }
        //If the filter free is true the computed distances between the own location and "Paulinenstraße 13/1" / "Rotebühlplatz(LBBW)" will be checked
        else if (free) {
            for toilet in computedDistances {
                if toilet.0 == "Paulinenstraße 13/1" {
                    XCTAssertEqual(toilet.1, 825, "Distance between specified location and the toilet's location is not like expected. Distance should be 825")
                }
                if toilet.0 == "Rotebühlplatz(LBBW)" {
                    XCTAssertEqual(toilet.1, 1018, "Distance between specified location and the toilet's location is not like expected. Distance should be 2207")
                }
            }
        }
        //If the filter barrierFree is true the computed distances between the own location and "Charlottenplatz 10" / "Schlossplatz, U-Bahn" will be checked
        else if (barrierFree) {
            for toilet in computedDistances {
                if toilet.0 == "Charlottenplatz 10" {
                    XCTAssertEqual(toilet.1, 905, "Distance between specified location and the toilet's location is not like expected. Distance should be 905")
                }
                if toilet.0 == "Schlossplatz, U-Bahn" {
                    XCTAssertEqual(toilet.1, 1267, "Distance between specified location and the toilet's location is not like expected. Distance should be 1267")
                }
            }
        }
        //If the free and barrierFree are false the computed distances between the own location and "Wilhelmsplatz" / "Holzstr./Dorotheenstr." will be checked
        else {
            for toilet in computedDistances {
                if toilet.0 == "Wilhelmsplatz" {
                    XCTAssertEqual(toilet.1, 607, "Distance between specified location and the toilet's location is not like expected. Distance should be 607")
                }
                if toilet.0 == "Holzstr./Dorotheenstr." {
                    XCTAssertEqual(toilet.1, 987, "Distance between specified location and the toilet's location is not like expected. Distance should be 987")
                }
            }
        }
        
    }
    
}
