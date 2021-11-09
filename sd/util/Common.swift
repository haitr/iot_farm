//
//  Common.swift
//  mdm_ios_swift
//
//  Created by Hai on 06/04/2017.
//  Copyright © 2017 AHope. All rights reserved.
//
import UIKit
import Foundation
import RxSwift

final class Common {
    
    // Can't init is singleton
    private init() { }
    
    //MARK: Shared Instance
    static let common: Common = Common()
    
    static let device: Device = Device.init()
    
}

extension Common {
    // MARK: UI
    func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(1.0), height: CGFloat(1.0))
        UIGraphicsBeginImageContext(rect.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
    
    static func needBigSize() -> Bool {
        if Common.device == .iPhone678P ||
            Common.device == .iPhoneX{
            return true
        }
        return false
    }
}

extension Common {
    // MARK: Alert
    func alertMessage(_ msg: String, title: String, in vc: UIViewController, withButtonAction buttonAction: [String: SimpleBlock]?) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        var buttonAction = buttonAction
        if buttonAction == nil {
            buttonAction = [NSLocalizedString("OK", comment: ""): NoActionBlock]
        }
        
        buttonAction?.keys.forEach({
            let buttonAct : SimpleBlock = buttonAction![$0]!
            let button = UIAlertAction(title: $0, style: .default, handler: {(_ action: UIAlertAction) -> Void in
                buttonAct()
            })
            alert.addAction(button)
        })
        
        vc.present(alert, animated: true, completion: nil)
    }
}

extension Common {
    // MARK: Store
    static let store: UserDefaults = UserDefaults.standard
    
    func get(_ key: Key) -> Any? {
        return Common.store.object(forKey: key.rawValue)
    }
    
    func set(_ obj: Any?, key: Key) {
        Common.store.set(obj, forKey: key.rawValue)
    }
    
    func remove(_ key: Key) {
        Common.store.removeObject(forKey: key.rawValue)
    }

}

extension Common {
    // MARK: User info
    func accessToken() -> String? {
        return get(Key.Token) as! String?
    }
    
    func setAccessToken(token: String) {
        set(token, key: Key.Token)
    }
    
    func removeAccessToken() {
        remove(Key.Token)
    }
    
    func rxToken() -> Observable<String?> {
        return Common.store.rx.observe(String.self, Key.Token.rawValue)
    }
    
}
