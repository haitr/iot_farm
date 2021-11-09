//
//  DSCircularView.swift
//  sd
//
//  Created by Hai on 07/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

@IBDesignable
class DSCircularView: UIView {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        //hard-coded this since it's always round
        layer.cornerRadius = 0.5 * bounds.size.width
    }
}
