//
//  Model.swift
//  need2pee
//
//  Created by Schlaue Füchse on 14.04.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import CoreData
import UIKit
import MapKit

class Model: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //Creating a model instance used throughout the code
    static let model = Model()
    
    //Variable for the mapView used in the main view
    var mapView : MKMapView?
    
    //Array containing the filtered set of toilets
    var resultsFiltered : [Toilet] = []
    
    //Array containing the full set of toilets
    var resultsFull : [Toilet] = []
    
    //Array containing the sorted keys
    var sortedKeys : Array<String> = []
    
    //Bools indicating whether a toilet is cost- and/or barrier-free
    var free : Bool = false
    var barrierFree : Bool = false
    
    override init(){
        super.init()
        //Boolean indicating whether it is the first start of the app or not
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if !launchedBefore {
            //The app was never launched before. Loading the JSON data into core data
            readJSONFile()
            //Setting the boolean to true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }
    
    /**
     Reading the data from the toilets.json file. This method is only called on the first start.
     */
    func readJSONFile(){
        let url = NSBundle.mainBundle().URLForResource("toilets", withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        do {
            //Storing the toilets in the variable objects
            let objects = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let toilets = objects as? [String: AnyObject] {
                addJSONtoCoreData(toilets)
            }
        } catch {
            print("Could not load the toilets, \(error)")
        }
    }
    
    /**
     Adding the data retrieved from the readJSONFile() method to core data.
     
     - parameters:
        - toiletObjects: Array containing the toilets from the JSON file.
     */
    func addJSONtoCoreData(toiletObjects: [String: AnyObject]) {
        let toilets = toiletObjects["toilets"] as? [[String: AnyObject]]
        
        for toilet in toilets! {
            //Setting the needed parameters for the saveToilet method from the JSON file
            let name = toilet["name"] as? String
            let descr = toilet["descr"] as? String
            let barrierFree = toilet["barrierFree"] as? Bool
            let free = toilet["free"] as? Bool
            let longitude = toilet["longitude"] as? Double
            let latitude = toilet["latitude"] as? Double
            saveToilet(name!, descr: descr!, free: free!, barrierFree: barrierFree!, longitude: longitude!, latitude: latitude!)
        }
    }
    
    /**
     Saving toilets to core data.
     
     - parameters:
        - name: String of the toilet's name.
        - descr: String with the toilet's description.
        - free: Boolean indicating whether the toilet is cost-free.
        - barrierFree: Boolean indicating whether the toilet is barrier-free.
        - longitude: The toilet's longitude.
        - latitude: The toilet's latitude.
     */
    func saveToilet(name: String, descr: String, free: Bool, barrierFree: Bool, longitude: Double, latitude: Double){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        do{
            let toilet = NSEntityDescription.insertNewObjectForEntityForName("Toilet",inManagedObjectContext:managedContext)
            
            //Setting the values for the toilet to be saved
            toilet.setValue(name, forKey: "name")
            toilet.setValue(descr, forKey: "descr")
            toilet.setValue(free, forKey: "free")
            toilet.setValue(barrierFree, forKey: "barrierFree")
            toilet.setValue(longitude, forKey: "longitude")
            toilet.setValue(latitude, forKey: "latitude")
            //Saving the toilet to core data
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save the toilet, maybe due to missing uniqueness. \(error), \(error.userInfo)")
        }
    }
    
    /**
     Fetching the core data
     
     - returns:
     An array with the toilets from core data that match the filter.
     
     - parameters:
        - free: Boolean indicating whether the toilet is cost-free.
        - barrierFree: Boolean indicating whether the toilet is barrier-free.
        - mapView: The MapView on which the fetched data is going to appear.
     */
    func fetchingCoreData(free: Bool, barrierFree: Bool, mapView: MKMapView) -> [Toilet]{
        self.mapView = mapView
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Toilet")

        do {
            //Setting the variables free and barrierFree so they can be used to compute the distance
            self.free = free
            self.barrierFree = barrierFree
            
            //Saving all toilets in the resultsFull array
            resultsFull = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]

            //It's either not free or not barrier-free or neither nor
            if(free && barrierFree){
                //Both are active
                fetchRequest.predicate = NSPredicate(format: "free == true && barrierFree == true")
            } else if (free) {
                //Only free active
                //return addFree(resultsFull)
                fetchRequest.predicate = NSPredicate(format: "free == true")
            } else if (barrierFree){
                //Only barrierFree active
                fetchRequest.predicate = NSPredicate(format: "barrierFree == true")
            }
            resultsFiltered = try managedContext.executeFetchRequest(fetchRequest) as! [Toilet]
            setPointAnnotations(resultsFiltered)
            
            return resultsFiltered
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return []
        }
    }
    
    /**
     Shows the given location in the middle of the map.
     
     - parameters:
        - locationLatitude: the latitude of the given location.
        - locationLongitude: the longitude of the given location.
     */
    func showMapMiddle(locationLatitude : CLLocationDegrees?,
                       locationLongitude : CLLocationDegrees?){
        
        let locationOne = CLLocationCoordinate2D(
            latitude: locationLatitude!, longitude: locationLongitude! //middle of the map
        )
        
        let span = MKCoordinateSpanMake(0.01, 0.01 )
        
        let region = MKCoordinateRegion(center: locationOne, span:span)
        
        mapView!.setRegion(region, animated: true)
    }
    
    /**
     Sets point annotations on the map.
     
     - parameters:
        - toilets: the fetched toilets matching the selected filters.
     */
    func setPointAnnotations(toilets: [Toilet]){
        for toilet in toilets {
            let location = CLLocationCoordinate2D(
                latitude: (toilet.valueForKey("latitude") as? Double)!, longitude: (toilet.valueForKey("longitude") as? Double)!)
            let annotation = MKPointAnnotation()
            mapView!.delegate = self
            annotation.coordinate = location
            //Setting the toilet's name as the title
            annotation.title = toilet.valueForKey("name") as? String
            //Setting the toilet's description as subtitle
            annotation.subtitle = toilet.valueForKey("descr") as? String
            mapView(mapView!, viewForAnnotation: annotation)!.annotation = annotation
            mapView!.addAnnotation(annotation)
        }
    }
    
    /**
     Selects point annotations on the map
     
     - parameters:
        - name: the toilet that should be displayed
     */
    
    func selectPointAnnotation(name: String){
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        for toilet in resultsFiltered{
            if toilet.name == name {
                let location = CLLocationCoordinate2D( latitude: (toilet.latitude as? Double)!, longitude: (toilet.longitude as? Double)!)
                showMapMiddle((toilet.latitude as? Double)!, locationLongitude: (toilet.longitude as? Double)!)
                let annotation = MKPointAnnotation()
                mapView!.delegate = self
                annotation.coordinate = location
                annotation.title = toilet.valueForKey("name") as? String
                annotation.subtitle = toilet.valueForKey("descr") as? String
                mapView(mapView!, viewForAnnotation: annotation)!.annotation = annotation
                mapView!.addAnnotation(annotation)
                mapView!.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "toiletAnnotation"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if annotationView == nil
        {
            //Creating a new annotation
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "toiletAnnotation")
            //Annotation is able to show additional info in "callout bubble" (name and description)
            annotationView!.canShowCallout = true
            //Setting own images for the toilets
            annotationView!.image = UIImage(named: "toilet")
        }
        else
        {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    /**
     Deletes a given toilet
     
     - parameters:
        - toiletName: the toilet that should be deleted
     */
    func deleteToilet(toiletName: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        for toilet in resultsFiltered{
            //Selecting the toilet matching the given name
            if toilet.valueForKey("name") as? String == toiletName{
                // Deleting it from the managedObjectContext
                managedContext.deleteObject(toilet)
                do{
                    try managedContext.save()
                }catch let error as NSError{
                    debugPrint(error)
                }
            }
        }
        
        //Removing all annotations except for the user's own location
        let annotationsToRemove = mapView!.annotations.filter { $0 !== mapView!.userLocation }
        mapView!.removeAnnotations(annotationsToRemove)
        
        //Fetching what is in core data to display it in the table and on the map
        fetchingCoreData(free, barrierFree: barrierFree, mapView: mapView!)
    }
    
    /**
     Computes the distance from the user's current location to the toilets
     
     - parameters:
        - ownLocationLatitude: the user's current location's latitude
        - ownLocationLongitude: the user's current location's longitude
     
     - returns: A map with the toilets' names and the corresponding distances to the user's current location
     */
    func computeDistances(ownLocationLatitude: Double, ownLocationLongitude: Double) -> [String: Int]{
        //Map that is to be returned storing the toilets' names and the corresponding distances
        var namesDistances = [String: Int]()
        for toilet in resultsFiltered {
            //The location of the found toilet
            let to = CLLocation(latitude: (toilet.valueForKey("latitude") as? Double)!, longitude: (toilet.valueForKey("longitude") as? Double)!)
            //The user's current location
            let current = CLLocation(latitude: ownLocationLatitude, longitude: ownLocationLongitude)
            //Return the distance in m
            //The key is the location of the toilet
            namesDistances[(toilet.valueForKey("name") as? String)!] = Int(round(current.distanceFromLocation(to)))
        }
        return namesDistances
    }
    
    /**
     Sorts the calculated distances from the user's current location to the toilets ascendingly
     
     - parameters:
        - namesDistances: the map containing the toilets' names and the corresponding distanes
     
     - returns: An array containing the toilets' names sorted after their distances to the user's current location in an ascending way
     */
    func keysSortedByValue(namesDistances: [String: Int]) -> Array<String>{
        let myKeys = Array(namesDistances.keys)
        let sortedKeys = myKeys.sort {
            //
            let toilet1 = namesDistances[$0]
            let toilet2 = namesDistances[$1]
            return toilet1! < toilet2!
        }
        return sortedKeys
    }
    
    /**
     Shows a toast message telling the user that he did not follow the insertion rules when entering data for a new toilet
     
     - parameters:
        - message: the message to be displayed
        - view: the view in which the message is to be displayed
        - yCoordinate: the y-coordinate of the message
        - height: the height of the shown message
     */
    func showToastMessage(message: String, view: UIView, yCoordinate: CGFloat, height: CGFloat){
        //Creating a new toast label
        let toastLabel = UILabel(frame: CGRectMake(view.frame.size.width/2 - (view.frame.size.width - 19)/2, yCoordinate, view.frame.size.width - 20, height))
        //Setting the toast label's style
        toastLabel.backgroundColor = UIColor.lightGrayColor()
        toastLabel.textColor = UIColor.whiteColor()
        toastLabel.textAlignment = NSTextAlignment.Center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds  =  true
        UIView.animateWithDuration(1.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            toastLabel.alpha = 0.0
            }, completion: {
                (value: Bool) in
                toastLabel.hidden = true
        })
    }
    
    /**
     Tests whether the name the user inserts already exists among the saved toilets
     
     - parameters:
        - name: the name the user inserted
     - returns: A boolean indicating whether the name already exists (false) or not
     */
    func testUniqueness(name: String) -> Bool {
        for toilet in resultsFull {
            if toilet.name == name {
                return false
            }
        }
        return true
    }
}
