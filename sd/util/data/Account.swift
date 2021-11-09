//
//  Account.swift
//  sd
//
//  Created by Hai on 21/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Account {

    static let account: Account = Account()
    
    private init() {
        rxThingInfo = BehaviorRelay(value: thingInformation)
        loadData()
    }
    
    let rx_rules = ReplaySubject<Rule>.create(bufferSize: 1)
    
    let disposeBag = DisposeBag()
    
    var thingInformation: [String:Any] = [:]
    
    let rxThingInfo: BehaviorRelay<[String:Any]>
    
    let rx_alarmPowerOn = BehaviorSubject<Bool>(value: true)
    let rx_alarmPowerOff = BehaviorSubject<Bool>(value: true)
    let rx_alarmCustom = BehaviorSubject<Bool>(value: true)
    let rx_alarmCustomAmount = BehaviorSubject<Bool>(value: true)
    let rx_alarmGatewayId = BehaviorSubject<String>(value: "")
    let rx_scheduleOn = BehaviorSubject<Bool>(value: true)
    let rx_scheduleOff = BehaviorSubject<Bool>(value: true)
    let rx_scheduleGatewayId = BehaviorSubject<String>(value: "")
    
    let rx_gateways = ReplaySubject<Gateway>.create(bufferSize: 1)
    
}

extension Account {
    func saveRule(_ rule: Rule) {
        rx_rules.onNext(rule)
    }
    
    private func registerParseAlarmState(_ rx: Observable<Rule>) {
        rx.filter{ $0.name.hasSuffix(ApiKey.AlarmState.rawValue) }
            .subscribe {
                let rule = $0.element!
                self.setAlarm(gatewayId: rule.pName, type: .powerOnId, value: rule.id)
                self.setAlarm(gatewayId: rule.pName, type: .powerOffId, value: rule.id)
                self.setAlarm(gatewayId: rule.pName, type: .powerOnActivated, value: false)
                self.setAlarm(gatewayId: rule.pName, type: .powerOffActivated, value: false)
                if (rule.status == "activated") {
                    self.setAlarm(gatewayId: rule.pName, type: .state, value: true)
                    var powerOn: Bool
                    var powerOff: Bool
                    if let values = ((rule.trigger["method"] as? [String:Any])?["in"] as? [String:Any])?["values"] as? String {
                        switch values {
                        case "0,1,2,3":
                            powerOn = true
                            powerOff = true
                        case "0,1,2":
                            powerOn = false
                            powerOff = true
                        case "3":
                            powerOn = true
                            powerOff = false
                        default:
                            powerOn = false
                            powerOff = false
                        }
                        self.setAlarm(gatewayId: rule.pName, type: .powerOnActivated, value: powerOn)
                        self.setAlarm(gatewayId: rule.pName, type: .powerOffActivated, value: powerOff)
                    }
                } else {
                    self.rx_alarmGatewayId.onNext(rule.pName)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func registerParseAlarm(_ rx: Observable<Rule>) {
        rx.filter{ $0.name.hasSuffix(ApiKey.Alarm.rawValue) }
            .subscribe {
                let rule = $0.element!
                self.setAlarm(gatewayId: rule.pName, type: .customId, value: rule.id)
                self.setAlarm(gatewayId: rule.pName, type: .customType, value: AlarmCustomType.no)
                if (rule.status == "activated") {
                    self.rx_alarmCustom.onNext(true)
                    self.setAlarm(gatewayId: rule.pName, type: .state, value: true)
                    if (((rule.trigger["method"] as? [String:Any])?["id"] as? [String:Any])?["over"] as? String) != nil {
                        self.setAlarm(gatewayId: rule.pName, type: .customType, value: AlarmCustomType.over)
                    }
                    if (((rule.trigger["method"] as? [String:Any])?["id"] as? [String:Any])?["under"] as? String) != nil {
                        self.setAlarm(gatewayId: rule.pName, type: .customType, value: AlarmCustomType.under)
                    }
                } else {
                    self.rx_alarmCustom.onNext(false)
                    self.rx_alarmGatewayId.onNext(rule.pName)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func registerAlarmAmount(_ rx: Observable<Rule>) {
        rx.filter{ $0.name.hasSuffix(ApiKey.AlarmAmount.rawValue) }
            .subscribe {
                let rule = $0.element!
                self.setAlarm(gatewayId: rule.pName, type: .customAmountId, value: rule.id)
                if (rule.status == "activated") {
                    self.rx_alarmCustomAmount.onNext(true)
                    self.setAlarm(gatewayId: rule.pName, type: .state, value: true)
                    self.setAlarm(gatewayId: rule.pName, type: .customAmountActivated, value: true)
                } else {
                    self.rx_alarmCustomAmount.onNext(false)
                    self.rx_alarmGatewayId.onNext(rule.pName)
                    self.setAlarm(gatewayId: rule.pName, type: .customAmountActivated, value: false)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func registerSchedulerOn(_ rx: Observable<Rule>) {
        rx.filter{ $0.name.hasSuffix(ApiKey.SchedulerOn.rawValue) }
            .subscribe {
                let rule = $0.element!
                self.setScheduler(gatewayId: rule.pName, type: .powerOnId, value: rule.id)
                if (rule.status == "activated") {
                    self.setScheduler(gatewayId: rule.pName, type: .state, value: true)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOnActivated, value: true)
                } else {
                    self.rx_scheduleOn.onNext(false)
                    self.rx_scheduleGatewayId.onNext(rule.pName)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOnActivated, value: false)
                }
                if let atEveryDayOfWeek = (rule.trigger["method"] as? [String:Any])?["atEveryDayOfWeek"] as? [String:Any] {
                    let dayOfWeek = atEveryDayOfWeek["dayOfWeek"] as? String
                    var hour = atEveryDayOfWeek["hour"] as! Int + 9
                    let minute = atEveryDayOfWeek["minute"] as! Int
                    if (hour > 24) {
                        hour = hour - 24;
                    }
                    self.setScheduler(gatewayId: rule.pName, type: .powerOnHour, value: hour)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOnMinute, value: minute)
                    if let dayOfWeek = dayOfWeek {
                        self.setScheduler(gatewayId: rule.pName, type: .daysOfWeek, value: dayOfWeek)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func registerSchedulerOff(_ rx: Observable<Rule>) {
        rx.filter{ $0.name.hasSuffix(ApiKey.SchedulerOff.rawValue) }
            .subscribe {
                let rule = $0.element!
                self.setScheduler(gatewayId: rule.pName, type: .powerOffId, value: rule.id)
                if (rule.status == "activated") {
                    self.setScheduler(gatewayId: rule.pName, type: .state, value: true)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOffActivated, value: true)
                } else {
                    self.rx_scheduleOff.onNext(false)
                    self.rx_scheduleGatewayId.onNext(rule.pName)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOffActivated, value: false)
                }
                if let atEveryDayOfWeek = (rule.trigger["method"] as? [String:Any])?["atEveryDayOfWeek"] as? [String:Any] {
                    let dayOfWeek = atEveryDayOfWeek["dayOfWeek"] as? String
                    var hour = atEveryDayOfWeek["hour"] as! Int + 9
                    let minute = atEveryDayOfWeek["minute"] as! Int
                    if (hour > 24) {
                        hour = hour - 24;
                    }
                    self.setScheduler(gatewayId: rule.pName, type: .powerOffHour, value: hour)
                    self.setScheduler(gatewayId: rule.pName, type: .powerOffMinute, value: minute)
                    if let dayOfWeek = dayOfWeek {
                        self.setScheduler(gatewayId: rule.pName, type: .daysOfWeek, value: dayOfWeek)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func registerAlarm() {
        Observable.combineLatest(rx_alarmGatewayId.asObservable(),
                                 rx_alarmPowerOn.asObservable(),
                                 rx_alarmPowerOff.asObservable(),
                                 rx_alarmCustom.asObservable(),
                                 rx_alarmCustomAmount.asObserver())
            .filter { $0.0 != "" && !$0.1 && !$0.2 && !$0.3 && !$0.4 }
            .subscribe {
                self.setAlarm(gatewayId: $0.element!.0, type: .state, value: false)
            }
            .disposed(by: disposeBag)
    }
    
    private func registerSchedule() {
        Observable.combineLatest(rx_scheduleGatewayId.asObservable(),
                                 rx_scheduleOn.asObservable(),
                                 rx_scheduleOff.asObservable())
            .filter { $0.0 != "" && !$0.1 && !$0.2 }
            .subscribe {
                self.setScheduler(gatewayId: $0.element!.0, type: .state, value: false)
            }
            .disposed(by: disposeBag)
    }
    
    func registerParseRule() {
        
        rxThingInfo.asObservable()
            .subscribe { self.saveData() }
            .disposed(by: disposeBag)
        
        let rx = rx_rules.share()
        registerParseAlarmState(rx)
        registerParseAlarm(rx)
        registerAlarmAmount(rx)
        registerSchedulerOn(rx)
        registerSchedulerOff(rx)
        registerAlarm()
        registerSchedule()
    }
}

extension Account {
    
    func getThingFailed(gateway:Gateway) -> Bool {
        if let id = gateway.id,
            let savedGateway = thingInformation[id] as? Gateway,
            let failed = savedGateway.failed
        {
            return failed
        }
        return false
    }
    
    func removeSavedGateway(gateway: Gateway) {
        if let id = gateway.id,
            let _ = thingInformation[id] {
            thingInformation.removeValue(forKey: id)
        }
    }
    
    func saveGateway(_ gateway: Gateway) {
        rx_gateways.onNext(gateway)
    }
    
    func registerParseGateway() {
        let rx = rx_gateways.share()
        
        rx.asObservable()
            .subscribe {
                if let gateway = $0.element {
                    if (self.getThingFailed(gateway: gateway)) {
                        self.removeSavedGateway(gateway: gateway)
                        Network.network.deleteGateway(gateway: gateway, index: 0)
                            .subscribe {
                                // request all gateways again
                            }
                            .disposed(by: self.disposeBag)
                    }
                }
            }
            .disposed(by: disposeBag)
        
    }
}

extension Account {
    
    private func saveDirectoryURL() -> String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
//        print("this is the url path in the documentDirectory \(String(describing: url))")
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        return (url!.appendingPathComponent("appData").path)
    }
    
    func saveData() {
        var dataDict: [String:Any] = [:]
        
        if thingInformation.count > 0 {
            dataDict["thingInformation"] = thingInformation
        }
        
        NSKeyedArchiver.archiveRootObject(dataDict, toFile:saveDirectoryURL())
    }
    
    func loadData() {
        let path = saveDirectoryURL()
        if FileManager.default.fileExists(atPath: path) {
            if let savedData = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String:Any] {
                if let savedThingInfomation = savedData["thingInformation"] as? [String:Any] {
                    thingInformation = savedThingInfomation
                } else {
                    thingInformation = [:]
                }
            }
        }
    }
}

extension Account {
    // Common rule
    func setAlarm<T>(gatewayId: String, type: Alarm, value: T) where T: ValueType{
        if (AlarmDefaultValue[type.rawValue]! >!< value) {
            print("Wrong type!")
            return
        }
        var thing = thingInformation[gatewayId] as? [String:Any] ?? [:]
        thing[type.rawValue] = value
        thingInformation[gatewayId] = thing
    }
    
    func getAlarm<T>(gatewayId: String, type: Alarm) -> T where T: ValueType {
        let def = AlarmDefaultValue[type.rawValue] as! T
        if let thing = thingInformation[gatewayId] as? [String:Any] {
            return thing[type.rawValue] as? T ?? def
        }
        return def
    }
    
    func setScheduler<T>(gatewayId: String, type: Scheduler, value: T) where T: ValueType{
        if (SchedulerDefaultValue[type.rawValue]! >!< value) {
            print("Wrong type!")
            return
        }
        var thing = thingInformation[gatewayId] as? [String:Any] ?? [:]
        thing[type.rawValue] = value
        thingInformation[gatewayId] = thing
    }
    
    func getScheduler<T>(gatewayId: String, type: Scheduler) -> T where T: ValueType {
        let def = SchedulerDefaultValue[type.rawValue] as! T
        if let thing = thingInformation[gatewayId] as? [String:Any] {
            return thing[type.rawValue] as? T ?? def
        }
        return def
    }
    
}

// Important for generics
protocol ValueType: Any {}
extension Bool: ValueType {}
extension Int: ValueType {}
extension String: ValueType {}
extension AlarmCustomType: ValueType {}

// Compare type of two objects
infix operator >!<

func >!< (object1: Any, object2: Any) -> Bool {
    return (object_getClassName(object1) == object_getClassName(object2))
}
