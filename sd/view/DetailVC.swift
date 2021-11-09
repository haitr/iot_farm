//
//  DetailVCViewController.swift
//  sd
//
//  Created by Hai on 05/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblGPS: UILabel!
    @IBOutlet weak var lblGauge: UILabel!
    @IBOutlet weak var lblConstruction: UILabel!
    
    var contactList:[Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        initContactList()
        initTableView()
        bindData()
        rxStatus()
    }
    
    func getInfo() {
        Network.network.getUserInfo()
            .subscribe {
                print("User info")
                print($0)
            }
            .disposed(by: disposeBag)
    }
    
    func initContactList() {
        var c:Contact
        c = Contact(title:"담당 공무원", name:"홍길동", phone:"123")
        contactList.append(c)
        c = Contact(title:"진단 전문가", name:"김철수", phone:"234")
        contactList.append(c)
        c = Contact(title:"시공 담당자", name:"이영희", phone:"345")
        contactList.append(c)
        c = Contact(title:"공사 감독관", name:"박감독", phone:"456")
        contactList.append(c)
        c = Contact(title:"현장 지휘자", name:"김현장", phone:"567")
        contactList.append(c)
    }
    
}

extension DetailVC {
    func initTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 51
    }
}

extension DetailVC {
    func bindData() {
        let list = Observable.just(contactList)
        list
            .bind(to: tableView.rx.items(cellIdentifier: "callCell", cellType: CallInfoCell.self)) {(row, element, cell) in
                cell.title.text = element.title
                cell.name.text = element.name
                //
                cell.btnCall.rx.tap
                    .bind {
                        if let url = URL(string: "tel:\(element.phoneNumber)") {
                            if (UIApplication.shared.canOpenURL(url)) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
    }
}

extension DetailVC {
    func rxStatus() {
        if (Bool.random()) {
            lblGPS.textColor = UIColor (named: "Color 3")
            lblGauge.textColor = UIColor (named: "Color 3")
            lblConstruction.textColor = UIColor (named: "Color 3")
        } else {
            lblGPS.textColor = UIColor (named: "Color 4")
            lblGauge.textColor = UIColor (named: "Color 4")
            lblConstruction.textColor = UIColor (named: "Color 4")
        }
    }
}
