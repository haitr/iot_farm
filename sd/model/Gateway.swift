//
//  Gateway.swift
//  sd
//
//  Created by Hai on 22/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

class Gateway {
    var id: String?
    
    var failed: Bool?
    
    var sensors: [Sensor] = []
    
    init(from dic:Any) {
        if let dic = dic as? [String:Any] {
            id = dic["id"] as? String
            failed = dic["isFailed"] as? Bool
            if let sensorData = dic["sensors"] as? [[String:Any]] {
                sensorData.forEach {
                    if let sensor = SensorFactory.from($0) {
                        sensors.append(sensor)
                    }
                }
            }
        }
    }
}
