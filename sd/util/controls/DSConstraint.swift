//
//  ControlExts.swift
//  sd
//
//  Created by Hai on 05/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

@IBDesignable
class DSLayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable
    var ab: CGFloat = 0.0 {
        didSet {
            if !Common.needBigSize(){
                constant = ab
            }
        }
    }
    
    @IBInspectable
    var cd: CGFloat = 0.0 {
        didSet {
            if Common.needBigSize(){
                constant = cd
            }
        }
    }
}
