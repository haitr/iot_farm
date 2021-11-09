//
//  Rules.swift
//  sd
//
//  Created by Hai on 21/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

class Rule {
    
    var name: String = "" {
        didSet {
            pName = name.components(separatedBy: "_")[0]
        }
    }
    
    var pName = ""
    
    var status: String = ""
    
    var id: Int = -1
    
    var trigger: [String: Any] = [:]
    
    init(from dic: Any) {
        if let dic = dic as? [String:Any] {
            name = dic["name"] as? String ?? ""
            status = dic["status"] as? String ?? ""
            id = dic["id"] as? Int ?? -1
            trigger = dic["trigger"] as? [String:Any] ?? [:]
        }
    }
}
