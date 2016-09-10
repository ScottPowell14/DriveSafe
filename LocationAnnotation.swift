//
//  LocationAnnotation.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var title : String?
    var color : UIColor?
    
    init(let coord : CLLocationCoordinate2D, let tit : String, let color : UIColor) {
        self.coordinate = coord
        self.title = tit
        self.color = color
    }
}
