//
//  DSView.swift
//  sd
//
//  Created by Hai on 06/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

@IBDesignable
class DSView: UIView {

    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            // important
            layer.masksToBounds = true
        }
    }

}
