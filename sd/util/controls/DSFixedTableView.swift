//
//  DSFixedTableView.swift
//  sd
//
//  Created by Hai on 06/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

class DSFixedTableView: UITableView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isScrollEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
