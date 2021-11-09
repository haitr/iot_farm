//
//  MainVC.swift
//  sd
//
//  Created by Hai on 05/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class MainVC: BaseVC {
    
    @IBOutlet weak var btnReload: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    let rx_gateways = ReplaySubject<Gateway>.create(bufferSize: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        bindButton()
        //
        initTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
        checkToken()
    }
    
}

//MARK: - Fetch data from server
extension MainVC {
    
    func fetchServerData() {
        requestRules()
        requestGateways()
    }
    
    func requestRules() {
        Network.network.getAllRules()
            .catchError {
                print($0)
                return Observable.never()
            }
            .subscribe {
                if let ele = $0.element,
                    let arr = ele as? Array<[String:Any]>{
                    arr.forEach {
                        Account.account.saveRule(Rule(from: $0))
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func requestGateways() {
        Network.network.getAllGateways()
            .catchError {
                print($0)
                return Observable.never()
            }
            .subscribe {
                if let ele = $0.element,
                    let arr = ele as? Array<[String:Any]>{
                    arr.forEach {
//                        print("Gateway: \($0)")
                        let gw = Gateway(from: $0)
                        Account.account.saveGateway(gw)
                        self.rx_gateways.onNext(gw)
                    }
                    
                }
            }
            .disposed(by: disposeBag)
    }
    
}

//MARK: - Validation
extension MainVC {
    
    func checkToken() {
        if let token = Common.common.accessToken() {
            print("Token start with: \(token[1...3])")
            fetchServerData()
        } else {
            print("Invalid token")
            performSegue(withIdentifier: "RequestToken", sender: nil)
        }
    }
}

//MARK: - TableView job
extension MainVC {
    
    func initTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.register(UINib(nibName: "locationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        tableView.register(UINib(nibName: "statisticCell", bundle: nil), forCellReuseIdentifier: "StatisticCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell")
        // please dont set File Owner to CustomTableViewCell class
        
        // Observe gateways
        rx_gateways.asObservable()
            // ordering LocationCell first
            .map { $0.sensors.sorted{ ($0 is LocationSensor) && !($1 is LocationSensor) } }
            .bind(to: tableView.rx.items) { (table, row, element) in
                if let sensor = element as? LocationSensor {
                    return self.generateLocationCell(from: sensor, in: table)
                } else if let sensor = element as? StrainSensor {
                    return self.generateStrainCell(from: sensor, in: table)
                } else if let sensor = element as? RotarySensor {
                    return self.generateRotaryCell(from: sensor, in: table)
                } else {
                    return table.dequeueReusableCell(withIdentifier: "EmptyCell")!
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func generateLocationCell(from sensor: LocationSensor, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        //
        cell.chart.rx_endDate!
            .flatMap { _ in Network.network.getStatisticData(sensor: sensor,
                                                             startDate: cell.chart.rx_startDate!.value,
                                                             endDate: cell.chart.rx_endDate!.value,
                                                             params: Network.locationSensorParams) }
            .do(onNext: {
                cell.chart.rallyLocation = self.extractCurrentLocation(from: $0)
            })
            .flatMap { self.extractLocationData(from: $0) }
            .bind(to: cell.chart.rx_data)
            .disposed(by: cell.disposeBag)
        return cell
    }
    
    private func generateStrainCell(from sensor: StrainSensor, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell") as! StatisticCell
        cell.title.text = "응력"
        cell.addition.text = String.init(format: "%.2f MPa", sensor.strength)
        // have to call everytime dequeueCell, idk why
        cell.chart.prepareButton()
        cell.chart.rx_endDate
            .flatMap { _ in Network.network.getStatisticData(sensor: sensor,
                                                             startDate: cell.chart.rx_startDate.value,
                                                             endDate: cell.chart.rx_endDate.value,
                                                             params: Network.commonSensorParams) }
            .flatMap { self.extractLineChartData(from: $0) }
            .subscribe(onNext: {
                cell.chart.clear()
                cell.chart.rx_data.onNext($0)
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
    
    private func generateRotaryCell(from sensor: RotarySensor, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell") as! StatisticCell
        cell.title.text = "경사도"
        cell.addition.text = String.init(format: "%.2f%%", sensor.speed)
        // have to call everytime dequeueCell, idk why
        cell.chart.prepareButton()
        cell.chart.rx_endDate
            .flatMap { _ in Network.network.getStatisticData(sensor: sensor,
                                                             startDate: cell.chart.rx_startDate.value,
                                                             endDate: cell.chart.rx_endDate.value,
                                                             params: Network.commonSensorParams) }
            .flatMap { self.extractLineChartData(from: $0) }
            .subscribe(onNext: {
                cell.chart.clear()
                cell.chart.rx_data.onNext($0)
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}

//MARK: - API data retrieve
extension MainVC {
    private func extractKey(array: [Double]) -> Observable<ChartKeyType> {
        return Observable.deferred {
            Observable.of(array)
            .map { $0.enumerated()
                // timestamp is in miliseconds, convert to seconds first
                .compactMap { $0 % 2 != 0 ? Date(timeIntervalSince1970: $1/1000) : nil } }
            // check later, why flatMap but map and enumurated
            .flatMap { Observable.from($0) }
        }
    }
    
    private func extractValue(array: [Double]) -> Observable<ChartValueType> {
        return Observable.deferred {
            Observable.of(array)
            .map { $0.enumerated().compactMap { $0 % 2 == 0 ? $1 : nil } }
            .map { ar -> [Double] in
                let min = ar.min()!
                let max = ar.max()!
                return ar.compactMap { ($0-min)/(max-min) }
            }
            .flatMap { Observable.from($0) }
        }
    }
    
    private func extractLineChartData(from: Any) -> Observable<ChartDataType> {
        return Observable.deferred {
            Observable.just(from)
            .map {
                if let rsp = $0 as? [String:Any],
                    let data = rsp["data"] as? [String: Any],
                    let series = data["series"] as? [String:Any],
                    let data1 = series["data"] as? [Double] {
                    return data1
                }
                return nil
            }
            .unwrap()
            .filter { $0.count > 0 }
            .flatMap {
                Observable
                    .zip(self.extractKey(array: $0), self.extractValue(array: $0))
                    .reduce(OrderedDictionary(), accumulator: { (r: ChartDataType, pair) -> ChartDataType in
                        let (k, v) = pair
                        var r = r
                        r[k] = v
                        return r
                    })
            }
        }
    }
    
    private func extractCurrentLocation(from: Any) -> CLLocation {
        if let rsp = from as? [String:Any],
            let data = rsp["data"] as? [String: Any],
            let series = data["series"] as? [String:Any],
            let d = series["value"] as? [String:Double] {
                let lat = d["lat"] ?? 0
                let lng = d["lng"] ?? 0
                return CLLocation(latitude: lat, longitude: lng)
            }
        return CLLocation(latitude: 0, longitude: 0)
    }
    
    private func extractLocationData(from: Any) -> Observable<[CLLocation]> {
        return Observable.deferred {
            Observable.just(from)
            .map {
                if let rsp = $0 as? [String:Any],
                    let data = rsp["data"] as? [String: Any],
                    let series = data["series"] as? [String:Any],
                    let data1 = series["data"] as? [Any] {
                    return data1
                }
                return nil
            }
            .unwrap()
            // extract array in which elements was at even index
            // get location with maximum distance from <initial>
            .map { (ar:[Any]) in
                ar.enumerated()
                  .compactMap { $0 % 2 == 0 ? $1 : nil }
                  .compactMap { self.locationFromJSONString($0 as! String) }
            }
        }
    }
    
    private func locationFromJSONString(_ json: String) -> CLLocation {
        do {
            if let obj = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!,
                                                          options: .allowFragments) as? Dictionary<String,Double> {
                let lat = obj["lat"] ?? 0
                let lng = obj["lng"] ?? 0
                return CLLocation(latitude: lat, longitude: lng)
            } else {
                print("Bad json string")
            }
        } catch let error as NSError {
            print(error)
        }
        return CLLocation(latitude: 0, longitude: 0)
    }
}

//MARK: - UI works
extension MainVC {
    
    func bindButton() {
        //
        btnReload.rx.tap.bind {_ in
            self.requestGateways()
        }.disposed(by: disposeBag)
        
    }
    
}
