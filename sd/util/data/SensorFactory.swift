//
//  SensorFactory.swift
//  sd
//
//  Created by Hai on 22/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import CoreLocation

class SensorFactory {
    static func from(_ dic:Any) -> Sensor? {
        var sensor: Sensor?
        if let dic = dic as? [String:Any] {
            if let stringType = dic["type"] as? String {
                switch stringType {
                case "strain":
//                    print("Parse strain")
                    sensor = StrainSensor()
                    if let series = dic["series"] as? [String:Any] {
                        if let value = series["value"] as? String {
                            (sensor as! StrainSensor).strength = Double(value) ?? 0
                        }
                    }
                case "location"    :
//                    print("Parse location")
//                    print("API res: \(dic)")
                    sensor = LocationSensor()
                    if let series = dic["series"] as? [String:Any] {
                        if let value = series["value"] as? [String:Any] {
                            if let lat = value["lat"] as? String,
                                let lon = value["lng"] as? String{
                                (sensor as! LocationSensor).location = CLLocation(latitude: Double(lat) ?? 0,
                                                                                  longitude: Double(lon) ?? 0)
                            }
                        }
                    }
                case "rotatyAngle" :
//                    print("Parse rotatyAngle")
                    sensor = RotarySensor()
                    if let series = dic["series"] as? [String:Any] {
                        if let value = series["value"] as? String {
                            (sensor as! RotarySensor).speed = Double(value) ?? 0
                        }
                    }
                default            : break
                }
            }
            sensor?.id       = dic["id"]        as? String ?? ""
            sensor?.deviceId = dic["deviceId"]  as? String ?? ""
            sensor?.name     = dic["name"]      as? String ?? ""
        }
        return sensor
    }
}
