//
//  CustomLabel.swift
//  mdm_ios_swift
//
//  Created by Hai on 06/04/2017.
//  Copyright © 2017 AHope. All rights reserved.
//

import UIKit

@IBDesignable
class DSLabel: UILabel {

    @IBInspectable
    var bigSize: CGFloat = 0.0 {
        didSet {
            if Common.needBigSize() {
                font = font.withSize(bigSize)
            }
        }
    }

}
