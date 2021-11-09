//
//  Contact.swift
//  sd
//
//  Created by Hai on 06/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var name:String
    var title:String
    var phoneNumber:String
    
    init(title:String, name:String, phone:String) {
        self.title = title
        self.name = name
        self.phoneNumber = phone
    }
}
