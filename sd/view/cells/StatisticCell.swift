//
//  StatisticCell.swift
//  sd
//
//  Created by Hai on 22/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift

class StatisticCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var addition: UILabel!
    
    @IBOutlet weak var chart: DSLineChartView!

    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
    }
}
