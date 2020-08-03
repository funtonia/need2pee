//
//  CoreDataTests.swift
//  need2pee
//
//  Created by Schlaue Füchse on 27.04.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import XCTest
import CoreData
@testable import need2pee

class CoreDataTests: XCTestCase {
    
    //This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    //This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    //Tests whether the CoreData is nil
    func testCoreDataNotNil() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Toilet")
        let fetchedEntities : [Toilet]
        do {
            fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]
            XCTAssertNotNil(fetchedEntities, "FetchRequest failed")
        } catch {
            print("FetchRequest failed (catch)")
        }
    }
    
    //Tests the amount of elements in CoreData
    func testCoreDataProperAmountOfElements() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Toilet")
        let fetchedEntities : [Toilet]
        do {
            fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]
            XCTAssertEqual(fetchedEntities.count, Model.model.resultsFull.count, "Fetched Amount of Toilets is not like expected")
        } catch {
            print("FetchRequest failed (catch)")
        }
    }
    
    //Tests the saveToilet() function
    func testSaveToiletFunction() {
        Model.model.saveToilet("Test Toilet", descr: "Great Toilet", free: true, barrierFree: true, longitude: 2.123, latitude: 3.123)
        let amountOfAlreadyExistingToilets = Model.model.resultsFull.count
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Toilet")
        let fetchedEntities : [Toilet]
        let fetchedEntitiesAfterDelete : [Toilet]
        do {
            fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]
            XCTAssertEqual(fetchedEntities.count, (amountOfAlreadyExistingToilets + 1), "Fetched Amount of Toilets is not like expected")
            XCTAssertEqual(fetchedEntities[amountOfAlreadyExistingToilets].name, "Test Toilet", "")
            XCTAssertEqual(fetchedEntities[amountOfAlreadyExistingToilets].descr, "Great Toilet", "")
            XCTAssertTrue(fetchedEntities[amountOfAlreadyExistingToilets].free as! Bool)
            XCTAssertTrue(fetchedEntities[amountOfAlreadyExistingToilets].barrierFree as! Bool)
            XCTAssertEqual(fetchedEntities[amountOfAlreadyExistingToilets].longitude, 2.123, "")
            XCTAssertEqual(fetchedEntities[amountOfAlreadyExistingToilets].latitude, 3.123, "")
            
            //Deletes the saved toilet from CoreData
            managedContext.deleteObject(fetchedEntities[amountOfAlreadyExistingToilets])
            do{
                try managedContext.save()
            }catch let error as NSError{
                debugPrint(error)
            }
            fetchedEntitiesAfterDelete = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]
            XCTAssertEqual(fetchedEntitiesAfterDelete.count, amountOfAlreadyExistingToilets, "Fetched Amount of Toilets is not like expected")
        } catch {
            print("FetchRequest failed (catch)")
        }
        
    }
    
}
