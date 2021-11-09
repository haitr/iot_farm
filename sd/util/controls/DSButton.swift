//
//  DSButton.m
//  mdm
//
//  Created by Hai on 03/03/2017.
//  Copyright © 2017 AHOPE admin. All rights reserved.
//
import UIKit

@IBDesignable
class DSButton: UIButton {
    
//    @IBInspectable
//    var borderWidth: CGFloat = 0.0 {
//        didSet {
//            layer.borderWidth = borderWidth
//        }
//    }
//
//    @IBInspectable var borderColor: UIColor {
//        didSet {
//            layer.borderColor = borderColor.cgColor
//        }
//    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            // important
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var backgroundColorOnHighlighted: UIColor = UIColor.clear {
        didSet {
            setBackgroundImage(Common.common.image(with: backgroundColorOnHighlighted), for: .highlighted)
            // important
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var backgroundColorOnDisabled: UIColor = UIColor.clear {
        didSet {
            setBackgroundImage(Common.common.image(with: backgroundColorOnDisabled), for: .disabled)
            // important
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var backgroundColorOnSelected: UIColor = UIColor.clear {
        didSet {
            setBackgroundImage(Common.common.image(with: backgroundColorOnSelected), for: .selected)
            // important
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var bigSize: CGFloat = 0.0 {
        didSet {
            if Common.device == .iPhone678P || Common.device == .iPhoneX {
                titleLabel?.font = titleLabel?.font.withSize(bigSize)
            }
        }
    }
    
    @IBInspectable var imageSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            if !Common.needBigSize() {
                updateImageView(size: imageSize)
            }
        }
    }
    
    @IBInspectable var bigImageSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            if Common.needBigSize() {
                updateImageView(size: bigImageSize)
            }
        }
    }
    
    func updateImageView(size:CGSize) {
        if let imageView = self.imageView {
            imageView.frame = CGRect(x: (self.frame.width - size.width)/2,
                                     y: (self.frame.height - size.height)/2,
                                     width: size.width,
                                     height: size.height)
        }
    }
    
//    @IBInspectable var alphaOnHighlighted: CGFloat = 0.0
//    
//    override var isHighlighted: Bool {
//        didSet {
//            if alphaOnHighlighted != 0.0 {
//                if isHighlighted {
//                    alpha = alphaOnHighlighted
//                }
//                else {
//                    alpha = 1
//                }
//            }
//
//        }
//    }
    
    @IBInspectable
    var selectionAreaPadding: CGFloat = 0.0
    
    override
    open
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bound: CGRect = bounds
        if selectionAreaPadding != 0.0 {
            bound = bound.insetBy(dx: CGFloat(-selectionAreaPadding),
                                  dy: CGFloat(-selectionAreaPadding))
        }
        return bound.contains(point)
    }
}
