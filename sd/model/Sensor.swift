//
//  Sensor.swift
//  sd
//
//  Created by Hai on 22/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import CoreLocation

protocol Sensor { // :Comparable for comparable or sort array
    var id       : String {get set}
    var deviceId : String {get set}
    var name     : String {get set}
}

class RotarySensor: Sensor {
    
    var id: String = ""
    
    var deviceId: String = ""
    
    var name: String = ""
    
    var speed: Double = 0.0
}

class LocationSensor: Sensor {
    var id: String = ""
    
    var deviceId: String = ""
    
    var name: String = ""
    
    var location: CLLocation = CLLocation()
}

class StrainSensor: Sensor {
    var id: String = ""
    
    var deviceId: String = ""
    
    var name: String = ""
    
    var strength: Double = 0.0
}

