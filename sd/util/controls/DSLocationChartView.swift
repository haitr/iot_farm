//
//  DSCoordinateChart.swift
//  sd
//
//  Created by Hai on 09/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

class DSLocationChartView: DSXibView {

    @IBOutlet weak var circleView: UIView!
    
    override func nibName() -> String? {
        return "locationChart"
    }

    @IBInspectable var knotColor: UIColor = UIColor.black
    
    @IBInspectable var knotSize: CGFloat = 0.0
    
    let rx_data = PublishSubject<[CLLocation]>()
    
    var rx_endDate: BehaviorRelay<Date>? = nil
    
    var rx_startDate: BehaviorRelay<Date>? = nil
    
    var rallyLocation: CLLocation = CLLocation(latitude: 0, longitude: 0) {
        didSet {
            internalMapView.frame = circleView.bounds
            internalMapView.centerCoordinate = rallyLocation.coordinate
            rallyPoint = toCGPoint(from: rallyLocation)
        }
    }
    
    private var rallyPoint: CGPoint = CGPoint(x:0, y:0)
    
    private var internalMapView = MKMapView()
    
    private var drawingPoint:[CGPoint] = []
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDate()
        rx_data.asObservable()
            .map { $0.map { self.toCGPoint(from: $0) } }
            .do(onNext: {
//                print("Drawing data: \($0)")
                self.drawingPoint = $0
                self.drawKnots()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func initDate() {
        let today = Calendar.current.date(bySettingHour: 0,
                                          minute: 0,
                                          second: 0,
                                          of: Date())!
        
        rx_startDate = BehaviorRelay<Date>(value: today)
        rx_endDate = BehaviorRelay<Date>(value: today)
        
        rx_endDate?
            .flatMap { Observable.just(Calendar.current.date(byAdding: .day, value: -5, to: $0)) }
            .unwrap()
            .bind(to: rx_startDate!)
            .disposed(by: disposeBag)
    }
    
    func toCGPoint(from: CLLocation) -> CGPoint {
        let res = internalMapView.convert(from.coordinate, toPointTo: circleView)
        return res
    }
    
    func distance(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        return (pow(lhs.x - rhs.x, 2) + pow(lhs.y - rhs.y, 2)).squareRoot()
    }
    
    var chartLayer: CAShapeLayer?
    func drawKnots() {
        if chartLayer == nil {
            chartLayer = CAShapeLayer()
            chartLayer!.frame = circleView.bounds
            chartLayer!.position = CGPoint(x: circleView.frame.width / 2,
                                           y: circleView.frame.height / 2)
            chartLayer!.path = CGMutablePath()
            //
            chartLayer!.strokeColor = knotColor.cgColor
            //
            circleView.layer.addSublayer(chartLayer!)
        }
        // calc x and y ratio
        let far = self.drawingPoint.max(by: {
            self.distance(from: $0, to: self.rallyPoint) < self.distance(from: $1, to: self.rallyPoint)
        })
//        print("rally: \(rallyPoint)")
//        print("far point: \(String(describing: far))")
        let rate = chartLayer!.frame.size.width/2/distance(from: far!, to: self.rallyPoint)
        //
//        print("rate: \(rate)")
        // draw
        drawingPoint.forEach() {
            let x = CGFloat($0.x - rallyPoint.x) * rate + chartLayer!.frame.size.width/2 - knotSize/2
            let y = CGFloat($0.y - rallyPoint.y) * rate + chartLayer!.frame.size.height/2 - knotSize/2
            let path = chartLayer!.path as! CGMutablePath
            path.addEllipse(in: CGRect(x: x, y: y, width: knotSize, height: knotSize))
//            print("draw on: (\(x),\(y))")
        }
    }
    
    func clear() {
        self.chartLayer?.removeFromSuperlayer()
        self.chartLayer = nil
        drawingPoint = []
    }
    
}
