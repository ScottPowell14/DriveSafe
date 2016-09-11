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
    
    
    
    
    @IBOutlet weak var animationContainerView: UIView!
    
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var kphLabel: UILabel!
    
    
    @IBOutlet weak var currentSafetyRatingLabel: UILabel!
    
    // Statistics Labels
    
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    @IBOutlet weak var numberOfSpeeds: UILabel!
    
    @IBOutlet weak var safetyRatingLabel: UILabel!
    
    @IBOutlet weak var numberOfCreditsLabel: UILabel!
    // Ride
    var currentRide : Ride?
    var collectionOfSpeeds : [CLLocationSpeed]?
    var collectionOfRatings : [Double]?

    
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
        
        self.collectionOfRatings = []
        
        // start tracking the driver's behavior
        self.currentRide = Ride(startLoc: startLocation!, endLoc: endLocation!)
        self.currentRide?.driverViewControllerRef = self
        self.currentRide?.startRide()
        
    }
    
    func startCarAnimation() {
        var imageCount = 1
        print("Got here")
        
        while imageCount <= 21 || (self.currentRide?.currentlyOnRide!)! {
            print(imageCount)
            sleep(1)
            let imageName = "car\(imageCount)"
            let image = UIImage(named: imageName)

            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.animationImageView.image = image
            })
            
            if imageCount == 21 {
                imageCount = 1
            } else {
                imageCount += 1
            }
            
            let imageName2 = "car\(imageCount)"
            let image2 = UIImage(named: imageName2)
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.animationImageView.image = image2
            })
            
            
            if imageCount == 21 {
                imageCount = 1
            } else {
                imageCount += 1
            }
        }
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
    
    func updateSpeedLabel(let currentSpeed : CLLocationSpeed) {
        if currentSpeed > 0.0 {
            
            let speedInKMH = currentSpeed * 3.6
            if speedInKMH >= 40.0 {
                self.kphLabel.textColor = UIColor.redColor()
            } else if speedInKMH >= 32.0 {
                self.kphLabel.textColor = UIColor(red: 244/255, green: 243/255, blue: 115/255, alpha: 1.0)
            } else {
                self.kphLabel.textColor = UIColor(red: 70/255, green: 192/255, blue: 91/255, alpha: 1.0)
            }
            
            self.kphLabel.text = "\(speedInKMH) KM/H"
            
            
            // Rating
            
            let ageGroup = 4
            let naturalLight = 1
            let vehicleType = 1
            let urbanisation = 0
            let baseSpeed = 20.0
            
            let agMult = (17 * ageGroup)
            let nlMult = (7 * naturalLight)
            
            var speedMult = Int(5 * (speedInKMH - baseSpeed))
            
            if speedMult <= 0 {
                speedMult = 1
            }
            
            let rating = Double(agMult + nlMult + speedMult + (4 * vehicleType) + (3 * urbanisation))
            
            let finalRating = Double(rating * 0.02)
            
            self.currentSafetyRatingLabel.text = "Current Safety Rating: \(finalRating)"
            self.collectionOfRatings?.append(Double(finalRating))
            
            
            
            
            
            
            
            
        } else {
            self.kphLabel.text = "Tracking KM/H"
            self.currentSafetyRatingLabel.text = "1.0"
        }
        
        
        
        
        
        
        
        
    }
    
    
    @IBAction func endRide(sender: AnyObject) {
        self.currentRide?.endRide()
    }
    
    
    func showRideFinishView() {
        
        self.calculateStatistics()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: .Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            self.view.addSubview(blurEffectView)
            // self.blurView = blurEffectView
        }
        self.view.bringSubviewToFront(self.rideFinishView)
        self.rideFinishView.hidden = false
        

    }
    
    
    func calculateStatistics() {
        
        var averageSpeed = 0.0
        
        for each in self.collectionOfSpeeds! {
            let kph = each * 3.6
            averageSpeed += kph
        }
        
        let average = averageSpeed / Double(self.collectionOfSpeeds!.count)
        self.avgSpeedLabel.text = "Average Speed: \(average) KM/H"
        
        var numberOfSpeedInfractions = 0
        var differentialsFromSpeedLimit : [Double] = []
        
        for each in self.collectionOfSpeeds! {
            let kph = each * 3.6
            
            if kph >= 20.0 {
                numberOfSpeedInfractions += 1
                differentialsFromSpeedLimit.append(kph - 20.0)
            }
        }
        
        self.numberOfSpeeds.text = "Speed Limit Infractions: \(numberOfSpeedInfractions)"
        
        // Average Rating
        
        var totalRating = 0.0
        var numberOfRatings = 1.0
        
        for each in self.collectionOfRatings! {
            totalRating += each
            numberOfRatings += 1.0
        }
        
        let averageRating = totalRating / numberOfRatings
        
        self.safetyRatingLabel.text = "Safety Rating: \(averageRating)"
        
        
        
        // Credits
        
        let credits = averageRating * 20.0
        
        self.numberOfCreditsLabel.text = "You've earned \(credits) credits!"
        3
        
    }
    
    
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("driverModeToProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segID = segue.identifier
        
        if segID == "driverModeToProfile" {
            let destinationViewController = segue.destinationViewController as! ProfileViewController
            
            // send over safety rating, time, and such
        }
    }
    
}
