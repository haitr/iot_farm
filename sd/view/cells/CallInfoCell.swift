//
//  CallInfoCell.swift
//  sd
//
//  Created by Hai on 06/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift

class CallInfoCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var btnCall: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
