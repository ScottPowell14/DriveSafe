//
//  Ride.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import Foundation
import MapKit

class Ride : NSObject, CLLocationManagerDelegate {
    
    // Ride State
    var rideInMaps : Bool?
    var currentlyOnRide : Bool?
    var driverViewControllerRef : DriverModeViewController?
    
    // Location
    var startLocation : CLLocation?
    var endLocation : CLLocation?
    let locationManager = CLLocationManager()
    
    // Ride Statistics
    var timeLengthOfRide : Int?
    var numberOfSpeedLimitInfractions : Int?
    var collectionOfSpeeds : [CLLocationSpeed]?
    
    
    // Timer
    var startTime : NSDate?
    var endTime : NSDate?
    var elaspedTime : NSTimeInterval?
    
    
    
    init(let startLoc : CLLocation, endLoc : CLLocation) {
        self.startLocation = startLoc
        self.endLocation = endLoc
        self.numberOfSpeedLimitInfractions = 0
        self.collectionOfSpeeds = []
        self.rideInMaps = false
        self.currentlyOnRide = true
    }
    
    func startRide() {
        // initialize in App Delegate
        if let myDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            myDelegate.currentRide = self
        }
        
        self.startTime = NSDate()
        locationManager.distanceFilter = 10
        locationManager.activityType = .Fitness
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func endRide() {
        self.currentlyOnRide = false
        self.endTime = NSDate()
        self.elaspedTime = NSDate().timeIntervalSinceDate(startTime!)
        print(self.elaspedTime!)
        self.driverViewControllerRef?.collectionOfSpeeds = self.collectionOfSpeeds
        self.driverViewControllerRef?.showRideFinishView()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.collectionOfSpeeds?.append(newLocation.speed)
        print(newLocation.speed)
    }
}