//
//  ViewController.swift
//  need2pee
//
//  Created by Schlaue Füchse on 22.03.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import UIKit
import CoreData
import MapKit

let url = NSBundle.mainBundle().URLForResource("toilets", withExtension: "json")
let data = NSData(contentsOfURL: url!)

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    //Variables used to set the location
    //let locationManager = CLLocationManager()
    var locationManager : CLLocationManager!
    var ownLocationLatitude : CLLocationDegrees?
    var ownLocationLongitude : CLLocationDegrees?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //fetching data -> if there is no core data (= if the app is opened for the first time), the data from the json file is added to core data
        self.locationManager.stopUpdatingLocation()
        if (fetchingCoreData(popOver.getFree(), barrierFree: popOver.getBarrierFree()).count == 0){
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if let toilet = object as? [String: AnyObject] {
                    addJSONtoCoreData(toilet)
                }
            } catch {
                print("Could not load the toilets, \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteToilets()

        //LocationManager configuration
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        locationManager.startUpdatingLocation()
        
        //set Point-Annotations on the map
        setPointAnnotations()
        
        //Do not display whitespace above cells
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //add the location to use it in the second view
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        //TableView code
        if (segue.identifier == "addToilet") {
            let tmp = segue!.destinationViewController as! TableViewController;
            
            tmp.passLongitude = ownLocationLongitude
            tmp.passLatitude = ownLocationLatitude
            
        }
        
        //Popover code
        if segue.identifier == "showPopOver" {
            //Creating an identifier for the popover view
            let popoverViewController = segue.destinationViewController as! PopoverViewController
            
            popoverViewController.popoverPresentationController?.delegate = self
        }

    }
    
    //Popover instance to access its variables
    let popOver = PopoverViewController()
    
    @IBAction func filterBtn(sender: AnyObject) {
    }
    
    @IBAction func gpsBtn(sender: AnyObject) {
        showMapMiddle(ownLocationLatitude, ownLocationLongitude: ownLocationLongitude)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Fetching old core data
    func fetchingCoreData(free: Bool, barrierFree: Bool) -> [Toilet]{
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Toilet")
        
        do {
            let resultsFull = try managedContext.executeFetchRequest(fetchRequest)
            var resultsFiltered = [Toilet]()
            if(!free && !barrierFree){
                //no filters selected; display all toilets
                return (resultsFull as? [Toilet])!
            }else{
                //it's either not free or not barrier-free or neither nor
                if(free && barrierFree){
                    //both are active
                    resultsFiltered.appendContentsOf(addFreeAndBarrierFree(resultsFull))
                } else if (free) {
                    //only free active
                    resultsFiltered.appendContentsOf(addFree(resultsFull))
                } else if (barrierFree) {
                    //only barrierFree active
                    resultsFiltered.appendContentsOf(addBarrierFree(resultsFull))
                    }
                return resultsFiltered
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return []
        }
    }
    
    //Adding free toilets to the array
    func addFree(resultsFull: [AnyObject]) -> [Toilet] {
        var resultsFreeFilter = [Toilet]()
        for toilet in resultsFull {
            //only appending toilets that do not free money
            if toilet.valueForKey("free") as? Bool == true {
                resultsFreeFilter.append(toilet as! Toilet)
            }
        }
        return resultsFreeFilter
    }
    
    //Adding barrierFree toilets to the array
    func addBarrierFree(resultsFull: [AnyObject]) -> [Toilet] {
        var resultsbarrierFreeFilter = [Toilet]()
        for toilet in resultsFull {
            if toilet.valueForKey("barrierFree") as? Bool == true {
                resultsbarrierFreeFilter.append(toilet as! Toilet)
            }
        }
        return resultsbarrierFreeFilter
    }
    
    //Adding toilets that are barrierFree and do not cost money
    func addFreeAndBarrierFree(resultsFull: [AnyObject]) -> [Toilet] {
        var resultsbarrierFreeFilter = [Toilet]()
        for toilet in resultsFull {
            if (toilet.valueForKey("barrierFree") as? Bool == true && toilet.valueForKey("free") as? Bool == true){
                resultsbarrierFreeFilter.append(toilet as! Toilet)
            }
        }
    return resultsbarrierFreeFilter
    }
    
    //Adding the data from our json file to core data
    func addJSONtoCoreData(object: [String: AnyObject]) {
        let toilets = object["toilets"] as? [[String: AnyObject]]
        
        for toilet in toilets! {
            let name = toilet["name"] as? String
            let descr = toilet["descr"] as? String
            let barrierFree = toilet["barrierFree"] as? Bool
            let free = toilet["free"] as? Bool
            let longitude = toilet["longitude"] as? Double
            let latitude = toilet["latitude"] as? Double
            saveToilet(name!, descr: descr!, free: free!, barrierFree: barrierFree!, longitude: longitude!, latitude: latitude!)
        }
    }
    
    //Inserting data
    func saveToilet(name: String, descr: String, free: Bool, barrierFree: Bool, longitude: Double, latitude: Double){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Toilet", inManagedObjectContext: managedContext)
        
        let toilet = Toilet(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        toilet.setValue(name, forKey: "name")
        toilet.setValue(descr, forKey: "descr")
        toilet.setValue(free, forKey: "free")
        toilet.setValue(barrierFree, forKey: "barrierFree")
        toilet.setValue(longitude, forKey: "longitude")
        toilet.setValue(latitude, forKey: "latitude")

        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save the toilet, \(error)")
        }
    }
    

    //TableView Code starts here
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return fetchingCoreData(popOver.getFree(), barrierFree: popOver.getBarrierFree()).count
    }
    
    func deleteToilets() {

        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Toilet")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            let cell =
            tableView.dequeueReusableCellWithIdentifier("toiletsDistance")
            
            let toilet = fetchingCoreData(popOver.getFree(), barrierFree: popOver.getBarrierFree())[indexPath.row]
            
            cell!.textLabel!.text = toilet.valueForKey("name") as? String
            
            //Adding the km to the label
            //cell!.detailTextLabel!.text = "\(computeDistance((toilet.valueForKey("latitude") as? Double)!, longitude: (toilet.valueForKey("longitude") as? Double)!)) km"
            
            return cell!
    }
    
    func reloadTableView(){
        tableView.reloadData()
    }
    
    //Show the position in the middle of the map
    func showMapMiddle(ownLocationLatitude : CLLocationDegrees?,
        ownLocationLongitude : CLLocationDegrees? ){
            
            let locationOne = CLLocationCoordinate2D(
                latitude: ownLocationLatitude!, longitude: ownLocationLongitude! //middle of the map
            )
            
            let span = MKCoordinateSpanMake(0.01, 0.01 )
            
            let region = MKCoordinateRegion(center: locationOne, span:span)
            
            mapView.setRegion(region, animated: true)
    }
    
    //Set Point Annotations on the Map
    func setPointAnnotations(){
        let toilets = fetchingCoreData(popOver.getFree(), barrierFree: popOver.getBarrierFree())
        for toilet in toilets {
            let location = CLLocationCoordinate2D(
            latitude: (toilet.valueForKey("latitude") as? Double)!, longitude: (toilet.valueForKey("longitude") as? Double)!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = toilet.valueForKey("name") as? String
            annotation.subtitle = toilet.valueForKey("descr") as? String
            mapView.addAnnotation(annotation)
            //TODO: eigene Bilder für Nadeln
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        //forcing popover style instead of complete viewchange
        return UIModalPresentationStyle.None
    }


}

//Location
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        
        ownLocationLatitude = location!.coordinate.latitude
        ownLocationLongitude = location!.coordinate.longitude
        
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
    //TODO: distance may only be computed AFTER map is loaded
    //compute the distance between the current location and the found toilets
//    func computeDistance(latitude: Double, longitude: Double) -> Double{
//        //The location of the found toilet
//        let to = CLLocation(latitude: latitude, longitude: longitude)
//        //The user's current location
//        let current = CLLocation(latitude: ownLocationLatitude!, longitude: ownLocationLongitude!)
//        //return the distance in km; rounded to one digit precision
//        return (round(10*(current.distanceFromLocation(to)/1000))/10)
//    }
}

