//
//  ProfileViewController.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // User information
    var name : String?
    var numberOfCredits : Int?
    var safetyRating : Int?
    var numberOfRides : Int?
    
    var historicalRides : [String : String]?
    var historicalRidesKeys : [String]?
    
    // UI Elements
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfCreditsLabel: UILabel!
    @IBOutlet weak var numberOfRidesLabel: UILabel!
    @IBOutlet weak var safetyRatingLabel: UILabel!
    
    
    let constants = Constants()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        historicalRides = ["9/10/16 (1)" : "4.5", "9/10/16 (2)" : "2.4", "9/10/16 (3)" : "3.2", "9/11/16 (1)" : "4.1", "9/11/16 (2)" : "1.5", "9/11/16 (3)" : "2.9", "9/11/16 (4)" : "4.9", "9/11/16 (5)" : "3.2", "9/11/16 (6)" : "4.3"]
        
        
        historicalRidesKeys = ["9/10/16 (1)", "9/10/16 (2)", "9/10/16 (3)", "9/11/16 (1)", "9/11/16 (2)", "9/11/16 (3)", "9/11/16 (4)", "9/11/16 (5)", "9/11/16 (6)"]
        
        historicalRidesKeys = historicalRidesKeys?.reverse()
        
        // status bar view and setting to color of background
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        let view = UIView(frame: statusBarFrame)
        view.backgroundColor = constants.overallColor
        self.view.addSubview(view)
        
        self.navBar.barTintColor = constants.overallColor
        
        self.profileImageView.image = UIImage(named: "headshot")
        self.profileImageView.layer.cornerRadius = view.frame.width / 8.0
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderWidth = 4.0
        self.profileImageView.layer.borderColor = UIColor(red: 126/255, green: 184/255, blue: 201/255, alpha: 1.0).CGColor
        
        self.nameLabel.text = "Scott"
        self.numberOfRidesLabel.text = "\(historicalRides!.count)"
        self.numberOfCreditsLabel.text = "1230"
        
        var averageSafetyRate = 0.0
        
        for each in (historicalRides?.values)! {
            averageSafetyRate += Double(each)!
        }
        
        let roundedAverageSafetyRate = Double(round(10*averageSafetyRate / Double((historicalRidesKeys?.count)!))/10)

        self.safetyRatingLabel.text = "\(roundedAverageSafetyRate)"
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return historicalRides!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        if indexPath.section == 1 {
            let dateAndTrialNumber = historicalRidesKeys![indexPath.row]
            cell.textLabel?.text = dateAndTrialNumber
            cell.detailTextLabel?.text = historicalRides![dateAndTrialNumber]
        } else {
            cell.textLabel?.text = "Historical Rides"
            cell.detailTextLabel?.text = "Safety Rating"
        }
        
        cell.userInteractionEnabled = false
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
