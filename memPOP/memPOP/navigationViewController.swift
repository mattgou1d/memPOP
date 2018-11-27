   //  navigationViewController.swift
   //  memPOP
   //  Group 9, Iota Inc.
   //  Created by Matthew Gould on 2018-11-10.
   //  Programmers: Nicholas Lau, Emily Chen, Matthew Gould, Diego Martin Marcelo
   //  Copyright © 2018 Iota Inc. All rights reserved.
   
   //===================================================================================================
   // Changes that have been made in v2.0
   // Created view controller to handle all of the navigation features for each hotspot selected
   // Fetch information about the hotspot selected
   // Show the route in mapView between the user's location and the hotspot address
   // Add named pins to the map view
   // Print walking/driving instructions to the output terminal
   
   import UIKit
   import CoreLocation
   import MapKit
   import CoreData
   
   
   // Consulted https://www.youtube.com/watch?v=vEN5WzsAoxA for customPin
   class customPin: NSObject, MKAnnotation {
    
    // Class "customPin" added to handle each pin added to the map view
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(pinTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.coordinate = location
    }
   }
   
   class navigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var doOnce: Bool = true
    var takeCar: Bool = false
    var selectedHotspot: NSManagedObject?
    var destinationName: String = ""
    var latitude:Double?
    var longitude:Double?
    var currentLatitude:Double?
    var currentLongitude:Double?
    var locationManager = CLLocationManager()
    var route:MKRoute?
    var routeSteps:Int = 0
    var touchedScreen:Bool = false
    var firstTouchLocation:CGPoint?
    var lastTouchLocation:CGPoint?
    
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet var mapOrDirectionsControl: UISegmentedControl!
    @IBOutlet var directionsTableView: UITableView!
    @IBOutlet var navigationView: UIView!
    
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Store the first touch location
        firstTouchLocation = touches.first?.location(in: mapkitView)
    
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Store the last touch location
        lastTouchLocation = touches.first?.location(in: mapkitView)
        
        // Check if the first touch and last touch location are the same
        if(lastTouchLocation == firstTouchLocation) {
            
            // Every touch toggles between showing the entire map view or not
            touchedScreen = !touchedScreen
            
            // If equal, choose to hide/show the subviews to show a larger map view
            if(!touchedScreen) {
                UIView.transition(with: navigationView, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
                // Hide subviews
                self.navigationView.sendSubview(toBack: mapkitView)
            }
            else {
                UIView.transition(with: navigationView, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
                // Show subviews
                self.navigationView.bringSubview(toFront: mapkitView)
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        touchedScreen = false
        directionsTableView.isHidden = true
        doOnce = true
        
        mapkitView.isRotateEnabled = true
        mapkitView.isPitchEnabled = true
        
        // Change appearance for segmented control
        mapOrDirectionsControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        mapOrDirectionsControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Request the user permission to use their location
        self.locationManager.requestWhenInUseAuthorization()
        
        // Check if permission is granted by the user
        if CLLocationManager.locationServicesEnabled(){
            
            print("location enabled")
            
            locationManager.delegate = self
            
            // Accuracy using GPS
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
            locationManager.startUpdatingLocation()
        }
        
        // Store the name of the destination for the selected hotspot
        destinationName = selectedHotspot?.value(forKey: "name") as! String
        
        // Fetch the latitude and longitude for the selected hotspot
        latitude = selectedHotspot?.value(forKey: "latitude") as? Double
        longitude = selectedHotspot?.value(forKey: "longitude") as? Double
        
        // For debugging
        print(latitude!)
        print(longitude!)
        
        // Check the method of transportation chosen for the selected hotspot
        if (selectedHotspot?.value(forKey: "transportation") as? String == "Car") {
            takeCar = true
        }
        else {
            takeCar = false
        }
        
    }
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // This function gets called whenever the user updates their location and updates the route
        
        //let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        let userLocal = locations.last
        
        // Store the user's current location
        currentLongitude = userLocal?.coordinate.longitude
        currentLatitude = userLocal?.coordinate.latitude
        
        
        if(mapOrDirectionsControl.selectedSegmentIndex == 1){
//            if let userLocation = locationManager.location?.coordinate {
//                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)
//                mapkitView.setRegion(viewRegion, animated: false)
//            }
            mapkitView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        }
    
        
        // For debugging
        print(currentLatitude!)
        
        // Only show the route once
        if(doOnce){
            layoutWalkingRoute()
            doOnce = false
        }
    }
    
    // Draw and display the walking route in blue
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        
        if (!takeCar) {
            renderer.lineDashPattern = [0, 15]
        }
        
        return renderer
    }
    
    // Get walking or driving directions
    // Consulted https://www.youtube.com/watch?v=nhUHzst6x1U for route directions
    func layoutWalkingRoute() {
        
        let sourceCoordinates = CLLocationCoordinate2DMake(currentLatitude!, currentLongitude!)
        let destCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        // Mark source and destination locations as pins on the map
        let sourcePin = customPin(pinTitle: " ", location: sourceCoordinates)
        let destPin =   customPin(pinTitle: destinationName, location: destCoordinates)
        self.mapkitView.addAnnotation(sourcePin)
        self.mapkitView.addAnnotation(destPin)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinates, addressDictionary: nil))
        
        // Check the method of transportation from the selected hotspot to display the appropiate route
        if (takeCar){
            request.transportType = .automobile
        }
        else {
            request.transportType = .walking
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            self.route = unwrappedResponse.routes[0]
            self.routeSteps = self.route!.steps.count
            
            for route in unwrappedResponse.routes {
                self.mapkitView.add(route.polyline)
                self.mapkitView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                for step in route.steps {
                    // Print the directions in the output window for debugging
                    print(step.instructions)
                    print(step.distance.description)
                }
            }
        }
    }
    
    @IBAction func changedNavMode(_ sender: Any){
        
        // Check method of navigation: Directions or Map overview
        
        if(mapOrDirectionsControl.selectedSegmentIndex == 0) {
            
            print("map")
            layoutWalkingRoute()
            directionsTableView.isHidden = true
        }
        else {
            
            print("directions")
            
            //Zoom to user location
            if let userLocation = locationManager.location?.coordinate {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)
                mapkitView.setRegion(viewRegion, animated: false)
            }
            
            directionsTableView.reloadData()
            directionsTableView.isHidden = false
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the number of sections in the directions table view
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of steps to get to the destination
       return routeSteps
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        let image: UIImage?
        
        // Process each step and update the table view cell accordingly
        
        if(indexPath.row == 0) {
            
            // The very first step shows the user's location
            
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            image = UIImage(named: "location")!
            cell?.textLabel?.text = "Your location"
        }
        else {
            
            // The rest of the steps show how to the destination

            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            let distanceInStep = self.route?.steps[indexPath.row].distance
            let stringInStep = self.route?.steps[indexPath.row].instructions
            var distanceInt = Int(distanceInStep!)
            
            // Check the direction per step to show the correct image
            if (stringInStep?.range(of: "left") != nil) {
                image = UIImage(named: "leftTurn")!
            }
            else if (stringInStep?.range(of: "right") != nil) {
                image = UIImage(named: "rightTurn")!
            }
            else {
                image = UIImage(named: "continue")!
            }
            
            // Check the distance per step
            if (distanceInt > 1000) {
                distanceInt = distanceInt / 1000
                cell?.textLabel?.text = "\(distanceInt) km"
            }
            else {
                cell?.textLabel?.text = "\(distanceInt) m"
            }
            
            // Show the step instruction
            cell!.detailTextLabel?.text = self.route?.steps[indexPath.row].instructions
        }
        
        // Attach the image
        cell?.imageView?.image = image
        
        // Resize the image within the cell
        let itemSize = CGSize.init(width: 27, height: 27)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell?.imageView?.image?.draw(in: imageRect)
        cell?.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Make the cell not selectable view the user
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell!
    }
    
}
   

