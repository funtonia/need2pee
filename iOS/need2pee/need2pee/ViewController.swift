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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    //Variables used to set the location
    var locationManager : CLLocationManager!
    var ownLocationLatitude : CLLocationDegrees?
    var ownLocationLongitude : CLLocationDegrees?
    
    //Boolean to store whether it is the first start or the refresh being executed every 8 seconds; false = first start
    var refresh: Bool = false
    
    //Variable that stores whether the user authorized the app to use his/her location
    var locationAuthState : CLAuthorizationStatus?

    //Map for the distances computed from the user's location to the toilets
    var namesDistances = [String: Int]()
    
    //Array for the keys belonging to the values of the namesDistances map. These are sorted from near to far
    var sortedKeys = Array<String>()
    
    //Default location used when the user does not authorize the app to use his/her location
    var defaultLocation : CLLocation = CLLocation(latitude: 48.773079, longitude: 9.176514)
    
    //Popover instance to access its variables
    let popOver = PopoverViewController()
    
    @IBOutlet weak var addToiletBtn: UIButton!
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Calling fetchingCoreData to get the current data
        Model.model.fetchingCoreData(popOver.getFree(), barrierFree: popOver.getBarrierFree(), mapView: mapView)
        
        //Table configuration
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        
        //Configuring the CLLocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Setting the locationAuthState to what the user chose from the popup asking him/her for permission
        locationAuthState = CLLocationManager.authorizationStatus()
        
        //If there is no answer yet, ask for the permission
        if(locationAuthState! == CLAuthorizationStatus.NotDetermined){
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Displaying the user's current location
        self.mapView!.showsUserLocation = true
        
        NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(self.refreshTableData), userInfo: nil, repeats: true)
    }
 
    /**
     Shows the user's current location by calling showMapMiddle() if GPS data may be used, an error message otherwise
     */
    @IBAction func gpsBtn(sender: AnyObject) {
        locationAuthState = CLLocationManager.authorizationStatus()
   
        if(locationAuthState! != CLAuthorizationStatus.AuthorizedWhenInUse){
            //User did not allow for GPS usage; error message is shown
            Model.model.showToastMessage("Please activate GPS services", view: self.view, yCoordinate: 80, height: 35)
        } else {
            //User did allow for GPS usage; his current location is shown
            locationManager.requestLocation()
            Model.model.showMapMiddle(ownLocationLatitude, locationLongitude: ownLocationLongitude)
        }
    }
    
    func refreshTableData() {
        locationManager.requestLocation()
    }
    
    //Preparing the different segues
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        //Segue going from the first view to the view where user can add toilets
        if (segue.identifier == "addToilet") {
            let tmp = segue.destinationViewController as! TableViewController;
            
            //Passing the user's longitude and latitude
            tmp.passLongitude = ownLocationLongitude
            tmp.passLatitude = ownLocationLatitude
            
        }
        
        //Segue going from the first view to the popover that contains the filters
        if segue.identifier == "showPopOver" {
            //Creating an identifier for the popover view
            let popoverViewController = segue.destinationViewController as! PopoverViewController
            
            popoverViewController.popoverPresentationController?.delegate = self
        }
    }
    
    //TableView Code starts here
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Defines how many rows there are going to be in the table
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return Model.model.resultsFiltered.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCellWithIdentifier("toiletsDistance")
        
        //Adding text to the toilet cells
        if (namesDistances.isEmpty){
            //No distances have been computed (yet), so the map is either not done loading yet or the user did not allow for GPS data
            let toilet = Model.model.resultsFiltered[indexPath.row]
            
            let toiletName = toilet.valueForKey("name") as? String
            
            cell!.textLabel!.text = toiletName
            //Displaying an empty String where the distance is normally displayed
            cell!.detailTextLabel!.text = ""
        } else {
            let toiletName = sortedKeys[indexPath.row]
            cell!.textLabel!.text = toiletName
            cell!.detailTextLabel!.textColor = UIColor(red: 0.8157, green: 0.5765, blue: 0, alpha: 1.0)
            //Displaying the distances
            cell!.detailTextLabel!.text = "\(namesDistances[(toiletName)]!) m"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        
        //Selecting the cell the user tapped to display details about the corresponding toilet
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
        Model.model.selectPointAnnotation(currentCell.textLabel!.text!)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Find the toilet the user is trying to delete and delete it
        if(editingStyle == .Delete ) {
            //Selecting the toilet the user tapped
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            let toiletName = currentCell.textLabel!.text
            //Delete the toilet
            Model.model.deleteToilet(toiletName!)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        //Forcing popover style instead of complete viewchange
        return UIModalPresentationStyle.None
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            //The user did authorize GPS usage
            locationManager.requestLocation()
            //Enable the button leading to the view where the user may save custom toilets
            addToiletBtn.enabled = true
        } else {
            //The user did not authorize GPS usage; show the default location specified above
            Model.model.showMapMiddle(defaultLocation.coordinate.latitude, locationLongitude: defaultLocation.coordinate.longitude)
            //Disable the button leading to the view where the user may save custom toilets
            addToiletBtn.enabled = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        
        if(refresh == false){
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView!.setRegion(region, animated: true)
            refresh = true;
        }
        
        //Setting the values for the user's current location
        ownLocationLatitude = location!.coordinate.latitude
        ownLocationLongitude = location!.coordinate.longitude
        
        //Adding the distance from the user's current location to the saved toilets
        namesDistances = [:]
        namesDistances = Model.model.computeDistances(ownLocationLatitude!, ownLocationLongitude: ownLocationLongitude!)
        sortedKeys = Model.model.keysSortedByValue(namesDistances)
        tableView.reloadData()
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

