//
//  HandleMapSearchProtocol.swift
//  DriveSafe
//
//  Created by Scott Powell on 9/10/16.
//  Copyright © 2016 Scott Powell. All rights reserved.
//

import Foundation
import MapKit


protocol HandleMapSearchProtocol {
    func userDidSelectDestination(placemark: MKPlacemark)
}