//
//  DSChartView.swift
//  sd
//
//  Created by Hai on 07/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DSLineChartView: DSXibView {

    var font: UIFont?
    @IBInspectable var labelFontSize: CGFloat = 10.0 {
        didSet {
            if !Common.needBigSize() {
                font = UIFont.systemFont(ofSize: labelFontSize)
            }
        }
    }
    
    @IBInspectable var labelBigFontSize: CGFloat = 12.0 {
        didSet {
            if Common.needBigSize() {
                font = UIFont.systemFont(ofSize: labelBigFontSize)
            }
        }
    }
    
    @IBInspectable var labelFontColor: UIColor = UIColor.black
    
    @IBInspectable var knotColor: UIColor = UIColor.black
    
    @IBInspectable var knotSize: CGFloat = 0.0
    
    @IBInspectable var knotBigSize: CGFloat = 0.0
    
    @IBInspectable var lineColor: UIColor = UIColor.black
    
    @IBInspectable var lineWeight: CGFloat = 1.0
    
    @IBOutlet weak var labelHolder: UIStackView!
    
    @IBOutlet weak var lineChartView: UIView!
    
    @IBOutlet weak var btnPrev: UIButton!
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var btnPrevView: UIView!
    
    @IBOutlet weak var btnNextView: UIView!
    
    let rx_data = PublishSubject<ChartDataType>()
    
    var rx_endDate: BehaviorRelay<Date>
    
    var rx_startDate: BehaviorRelay<Date>
    
    let disposeBag = DisposeBag()
    
    override func nibName() -> String? {
        return "lineChart"
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let today = Calendar.current.date(bySettingHour: 0,
                                          minute: 0,
                                          second: 0,
                                          of: Date())!
        
        rx_startDate = BehaviorRelay<Date>(value: today)
        rx_endDate = BehaviorRelay<Date>(value: today)
        
        super.init(coder: aDecoder)
        
        //
        rx_endDate
            .flatMap { Observable.just(Calendar.current.date(byAdding: .day, value: -5, to: $0)) }
            .unwrap()
            .bind(to: rx_startDate)
            .disposed(by: disposeBag)
        
        // draw labels when rx_data changed
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        let rx_margin = PublishSubject<CGFloat>()
        let rx_width = PublishSubject<CGFloat>()
        rx_data.asObservable()
            .map {
                Array($0.keys)
                    .enumerated()
                    .compactMap {(arg) -> String in
                        let (_, ele) = arg;
//                        print(ele)
                        return df.string(from: ele)
                    }
            }
            .flatMap{ Observable.from($0) }
            .map{ self.createLabelView($0) }
            .subscribe {
                //
                rx_width.onNext($0.element!.frame.size.width)
                // add labels
                self.labelHolder.addArrangedSubview($0.element!)
                self.labelHolder.layoutIfNeeded()
                // draw knot
                let knowFrame = self.labelHolder.arrangedSubviews.last?.frame
                rx_margin.onNext(knowFrame!.origin.x)
            }
            .disposed(by: disposeBag)
        // draw line chart when ..
        let rx_value = rx_data.asObservable()
                            .flatMap{ Observable.from(Array($0.values)) }
        Observable.zip(rx_margin, rx_width, rx_value)
            .subscribe {
                let (margin, width, value) = $0.element!
                self.drawLineChart(x: margin + width/2, value: value)
            }
            .disposed(by: disposeBag)
    }
    
    func clear() {
        self.labelHolder.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.lineChartLayer?.removeFromSuperlayer()
        self.lineChartLayer = nil
        lastPoint = nil
    }
    
    func prepareButton() {
        // Disable 'next' button when end date is today
        rx_endDate
            .flatMap { Observable.of(Calendar.current.isDateInToday($0)) }
            .bind(to: btnNextView.rx.isHidden)
            .disposed(by: disposeBag)
        //
        btnPrev.rx.tap.bind { _ in
            self.rx_endDate.accept(self.rx_startDate.value)
        }.disposed(by: disposeBag)
        
        btnNext.rx.tap.bind { _ in
            let date = self.rx_endDate.value
            self.rx_endDate.accept(Calendar.current.date(byAdding: .day, value: 5, to: date)!)
        }.disposed(by: disposeBag)
    }
    
    var lineChartLayer: CAShapeLayer?
    var lastPoint: CGPoint?
    func drawLineChart(x:CGFloat, value:Double) {
        if lineChartLayer == nil {
            lineChartLayer = CAShapeLayer()
            lineChartLayer!.frame = lineChartView.bounds
            lineChartLayer!.position = CGPoint(x: lineChartView.frame.width / 2, y: lineChartView.frame.height / 2)
            lineChartLayer!.path = CGMutablePath()
            //
            lineChartLayer!.strokeColor = lineColor.cgColor
            lineChartLayer!.lineWidth = lineWeight
            //
            lineChartView.layer.addSublayer(lineChartLayer!)
        }
        //
        let x = x - knotSize/2
        let y = lineChartLayer!.frame.size.height * CGFloat(value) - knotSize/2
        //
        let path = lineChartLayer!.path as! CGMutablePath
        let size = Common.needBigSize() ? knotBigSize : knotSize
        path.addEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        //
        let currentPoint = CGPoint(x: x + size/2, y: y + size/2)
        if let lastPoint = lastPoint {
            path.move(to: lastPoint)
            path.addLine(to: currentPoint)
        }
        lastPoint = currentPoint
    }
    
    func createLabelView(_ name:String) -> UILabel {
        let lbl = UILabel()
        lbl.text = name
        lbl.font = self.font
        lbl.textColor = self.labelFontColor
        lbl.sizeToFit()
        return lbl
    }
    
}
