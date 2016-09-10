//
//  DriverModeViewController.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import UIKit
import MapKit

class DriverModeViewController: UIViewController {
    
    // Location
    var startLocation : CLLocation?
    var endLocation : CLLocation?
    
    // UI Elements
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var endRideButton: UIButton!
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var rideFinishView: UIView!
    @IBOutlet weak var speedTextView: UITextView!
    
    
    
    
    // Ride
    var currentRide : Ride?
    var collectionOfSpeeds : [CLLocationSpeed]?

    
    let constants = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // status bar view and setting to color of background
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        let view = UIView(frame: statusBarFrame)
        view.backgroundColor = constants.overallColor
        self.view.addSubview(view)
        
        navBar.barTintColor = constants.overallColor
        endRideButton.backgroundColor = constants.overallColor
        openInMapsButton.backgroundColor = constants.overallColor
        
        
        // start tracking the driver's behavior
        self.currentRide = Ride(startLoc: startLocation!, endLoc: endLocation!)
        self.currentRide?.driverViewControllerRef = self
        self.currentRide?.startRide()
        
    }
    
    @IBAction func openInMaps(sender: AnyObject) {
        let regionDistance:CLLocationDistance = 2000
        if let coordinates = currentRide?.endLocation?.coordinate {
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Destination"
            currentRide?.rideInMaps = true
            mapItem.openInMapsWithLaunchOptions(options)
        }
    }
    
    
    @IBAction func endRide(sender: AnyObject) {
        self.currentRide?.endRide()
    }
    
    
    func showRideFinishView() {
        self.rideFinishView.hidden = false
        
        for each in self.collectionOfSpeeds! {
            let kph = each * 3.6
            self.speedTextView.text = self.speedTextView.text + " \(kph)"
        }
        
        
    }
    
    
}
