//
//  MapVC.swift
//  sd
//
//  Created by Hai on 05/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import MapKit

class MapVC: BaseVC {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView();
    }
    

    func initMapView() {
        //
    }

}
