//
//  DSDashLine.swift
//  sd
//
//  Created by Hai on 07/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

@IBDesignable
class DSDashLine: UIView {

    var border: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var vertical: Bool = true {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        border.removeFromSuperlayer()
        //
        self.backgroundColor = UIColor.clear
        border.frame = self.bounds
        border.fillColor = nil
        border.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        //
        border.strokeColor = borderColor.cgColor
        border.lineWidth = borderWidth
        border.lineJoin = CAShapeLayerLineJoin.round
        border.lineDashPattern = [1, 1]
        //
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        if (vertical) {
            path.addLine(to: CGPoint(x: 0, y: frame.height))
        } else {
            path.addLine(to: CGPoint(x: frame.width, y: 0))
        }
        border.path = path
        //
        self.layer.addSublayer(border)
    }

}
