//
//  BaseVC.swift
//  sd
//
//  Created by Hai on 05/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseVC: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        self.setNeedsStatusBarAppearanceUpdate()
        super.viewDidLoad()
    }
    

    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
