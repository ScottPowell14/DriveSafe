//
//  ViewController.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import UIKit
import MapKit


// View Controller for Start Ride View
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    // Location Manager Reference
    let locationManager = CLLocationManager()
    
    // Reference to constants
    let constants = Constants()
    
    // UI References
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var startRideButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startLocationSearchBar: UISearchBar!
    @IBOutlet weak var destinationLocationSearchBar: UISearchBar!
    
    // Search Controller
    var resultSearchController : UISearchController? = nil
    var destinationSearchBarReference : UISearchBar? = nil
    
    // User Information
    var userStartLocation : CLLocation?
    var userDestinationLocation : CLLocation?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // status bar view and setting to color of background
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        let view = UIView(frame: statusBarFrame)
        view.backgroundColor = constants.overallColor
        self.view.addSubview(view)
        
        // View Color config
        navBar.barTintColor = constants.overallColor
        startRideButton.backgroundColor = constants.overallColor
        
        // Keyboard dismissal gesture recognizer
        let keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.userTappedMapBackground))
        self.mapView.addGestureRecognizer(keyboardDismissGesture)
    
        
        // delegate assignments
        mapView.delegate = self
        locationManager.delegate = self
        
        // location manager config
        if CLLocationManager.locationServicesEnabled() {
            // centerOnUserLocation method
            // place user annotation
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        // search bar config
        self.startLocationSearchBar.backgroundImage = UIImage()
        self.startLocationSearchBar.userInteractionEnabled = false
        let textFieldInsideStartSearchBar = self.startLocationSearchBar.valueForKey("searchField") as? UITextField
        textFieldInsideStartSearchBar?.textColor = constants.overallColor
        textFieldInsideStartSearchBar?.font = UIFont(name: "HelveticaNeueThin", size: 18)
        textFieldInsideStartSearchBar?.textAlignment = .Center
        
        self.destinationLocationSearchBar.backgroundImage = UIImage()
//        let textFieldInsideDestinationSearchBar = self.destinationLocationSearchBar.valueForKey("searchField") as? UITextField
//        textFieldInsideDestinationSearchBar?.textColor = constants.overallColor
//        textFieldInsideDestinationSearchBar?.font = UIFont(name: "HelveticaNeueThin", size: 18)
//        textFieldInsideDestinationSearchBar?.textAlignment = .Center
        
        // Location Search Table
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        self.resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        self.resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = self.mapView
        
//        let newSearchBar = self.resultSearchController?.searchBar
//        newSearchBar?.sizeToFit()
//        newSearchBar?.placeholder = "Destination"
//        newSearchBar?.frame = self.destinationLocationSearchBar.frame
//        newSearchBar?.addConstraints(self.destinationLocationSearchBar.constraints)
//        newSearchBar?.backgroundImage = UIImage()

        self.resultSearchController?.searchBar.sizeToFit()
        self.resultSearchController?.searchBar.placeholder = "Destination"
        
//        self.resultSearchController?.searchBar.frame = CGRect(x: 0, y: 0, width: self.destinationLocationSearchBar.frame.width, height: self.destinationLocationSearchBar.frame.height)
        
        
        self.resultSearchController?.searchBar.frame = self.destinationLocationSearchBar.frame
        
        self.resultSearchController?.searchBar.addConstraints(self.destinationLocationSearchBar.constraints)
        
        
//        let centerLayoutConstraint = NSLayoutConstraint(item: self.resultSearchController.s, attribute: .CenterX, relatedBy: .Equal, toItem: self.destinationLocationSearchBar, attribute: .CenterX, multiplier: 1, constant: 0)
//        centerLayoutConstraint.
        
        self.resultSearchController?.searchBar.backgroundImage = UIImage()
        // self.resultSearchController
        
        self.destinationSearchBarReference = self.resultSearchController?.searchBar
        
        
        
        locationSearchTable.handleMapSearchDelegate = self
//        self.destinationLocationSearchBar.addSubview((self.resultSearchController?.searchBar)!)
        self.view.addSubview((self.resultSearchController?.searchBar)!)
        self.resultSearchController?.hidesNavigationBarDuringPresentation = false
        self.resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        // self.resultSearchController?.searchBar.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if startLocationSearchBar.isFirstResponder() {
            startLocationSearchBar.resignFirstResponder()
        }
        
        if destinationLocationSearchBar.isFirstResponder() {
            destinationLocationSearchBar.resignFirstResponder()
        }
        
        return true
    }
    
    func userTappedMapBackground() {
        view.endEditing(true)
    }
    
    
    // Location Manager Authorization
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            print("We have authorization")
            mapView.showsUserLocation = true
            self.centerOnUser()
            self.placeStartLocationAnnotation()
        } else {
            print("Do not have authorization")
        }
    }
    
    
    // Setting user's start location methods
    
    func centerOnUser() {
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        
        if let coord = locationManager.location?.coordinate {
            let mapRegion = MKCoordinateRegion(center: coord, span: mapSpan)
            mapView.setRegion(mapRegion, animated: true)
        } else {
            print("Do not have authorization")
        }
    }
    
    
    func placeStartLocationAnnotation() {
        // remove any current annotations if necessary
        if let coord = locationManager.location?.coordinate {
            self.userStartLocation = locationManager.location
            let locationAnnotation = LocationAnnotation(coord: coord, tit: "Start Location", color: UIColor.greenColor())
            mapView.addAnnotation(locationAnnotation)
            self.updateStartLocationWithPinLocation(coord)
        }
    }
    
    func updateStartLocationWithPinLocation(let newCoord : CLLocationCoordinate2D) {
        
        let locationOfCoord = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
        
        let geoCoder = CLGeocoder()
        var addressString : String?
        
        geoCoder.reverseGeocodeLocation(locationOfCoord, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print("Error getting location address string")
                return
            }
            
            if let places = placemarks {
                let startLocationPlacemark = places[0]
                
                let mapPlacemark = MKPlacemark(placemark: startLocationPlacemark)
                addressString = self.parseAddress(mapPlacemark)
            }
            
            if let address = addressString {
                self.startLocationSearchBar.text = address
            }
        })
    }
    
    
    
    
    // Map View delegate methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var locationAnnotationViewBase = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if locationAnnotationViewBase == nil {
            let locationAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            if annotation.isMemberOfClass(LocationAnnotation) {
                locationAnnotationView.draggable = false
                locationAnnotationView.canShowCallout = true
                
                let tempAnnotation = annotation as! LocationAnnotation
                locationAnnotationView.pinTintColor = tempAnnotation.color
            }
            
            locationAnnotationViewBase = locationAnnotationView
        }
        
        
        return locationAnnotationViewBase
    }
    
    
    // parse address
    func parseAddress(selectedItem : MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : " "
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : HandleMapSearchProtocol {
    func userDidSelectDestination(placemark: MKPlacemark) {
        print("User selected destination")
        
        // update search bar text and do rudimentary routing
    }
}


