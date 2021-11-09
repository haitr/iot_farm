//  Setting.swift
//  mdm_ios_swift
//
//  Created by Hai on 06/04/2017.
//  Copyright © 2017 AHope. All rights reserved.
//

import Foundation
import UIKit

public enum Device {
    case iPhone4        //iPhone 4
    case iPhone5        //iPhone 5
    case iPhone678      //iPhone 6 + 7 + 8
    case iPhone678P     //iPhone 6Plus + 7Plus + 8Plus
    case iPhoneX        //iPhone X
    case Unknown
    
    public init() {
        self = Device.map()
    }
    
    static func map() -> Device {
        if (Device.isPhone && max(Device.screenWidth, Device.screenHeight) == 812) {
            return .iPhoneX
        }
        if (Device.isPhone && min(Device.screenWidth, Device.screenHeight) == 414) {
            return .iPhone678P
        }
        if (Device.isPhone && max(Device.screenWidth, Device.screenHeight) == 667) {
            return .iPhone678
        }
        if (Device.isPhone && max(Device.screenWidth, Device.screenHeight) < 568) {
            return .iPhone4
        }
        if (Device.isPhone && max(Device.screenWidth, Device.screenHeight) == 568) {
            return .iPhone5
        }
        return .Unknown
    }
    
    static var isPhone : Bool {
        return (UIDevice.current.model == "iPhone")
    }
    
    static var screenWidth : CGFloat {
        return (UIScreen.main.bounds.size.width)
    }
    
    static var screenHeight : CGFloat {
        return (UIScreen.main.bounds.size.height)
    }
}

typealias CompleteBlock = (Any) -> Void

typealias FailBlock = (NSError) -> Void

typealias SimpleBlock = () -> Void

let NoCompleteActionBlock = {(_ res: Any) -> Void in
    
}

let NoFailActionBlock = {(_ er: Error?) -> Void in
    
}

let NoActionBlock = {() -> Void in
    
}

let ServerSuccess = 200
enum ServerError : Int {
    case noInternet
    case serverTimeout
    case serverInvalidToken
    case serverUnknown = 999
}

enum Key : String {
    case Token = "token"
}

enum Parameter : String {
    case Token = "token"
}

enum ApiKey : String {
    case Token        = "access-token"
    case AlarmState   = "_alerm_state"
    case Alarm        = "_alerm"
    case AlarmAmount  = "_alerm_amount"
    case SchedulerOn  = "_scheduler_on"
    case SchedulerOff = "_scheduler_off"
}

// Mark: Device state
enum DeviceConnectedTo{
    case DeviceConnectedToAirConditioner
    case DeviceConnectedToBidet
    case DeviceConnectedToElectricFan
    case DeviceConnectedToEtc
    case DeviceConnectedToLight
    case DeviceConnectedToMat
    case DeviceConnectedToNotebook
    case DeviceConnectedToPc
    case DeviceConnectedToRadiator
    case DeviceConnectedToRefrigerator
    case DeviceConnectedToSettopBox
    case DeviceConnectedToTv
    case DeviceConnectedToWasher
}

enum AlarmCustomType{
    case no
    case over
    case under
    case overDegree
    case underDegree
}

//Mark: gateway keys
enum Alarm: String {
    case state                    = "alarmState" // Bool = false
    case powerOnId                = "alarmPowerOnId" // Int = 0
    case powerOnActivated         = "alarmPowerOnActivated" // Bool
    case powerOffId               = "alarmPowerOffId" // Int
    case powerOffActivated        = "alarmPowerOffActivated" // Bool
    case customId                 = "alarmCustomId" // Int
    case customType               = "alarmCustomType" // AlarmCustomType = AlarmCustomTypeNo
    case customOverPower          = "alarmCustomOverPower" // Int = 20
    case customUnderPower         = "alarmCustomUnderPower" // Int = 20
    case customPercentOverPower   = "alarmCustomPercentOverPower" // Int = 20
    case customPercentUnderPower  = "alarmCustomPercentUnderPower" // Int = 20
    case customPercentOverDegree  = "alarmCustomPercentOverDegree" // Int = 10
    case customPercentUnderDegree = "alarmCustomPercentUnderDegree" // Int = 10
    case customAmountId           = "alarmCustomAmountId" // Int = 0
    case customAmountActivated    = "alarmCustomAmountActivated" // Bool = false
    case customAmountPower        = "alarmCustomAmountPower" // Int = 200
}
let AlarmDefaultValue: [String: Any] = [
    "alarmState"                    :false,
    "alarmPowerOnId"                :0,
    "alarmPowerOnActivated"         :false,
    "alarmPowerOffId"               :0,
    "alarmPowerOffActivated"        :false,
    "alarmCustomId"                 :0,
    "alarmCustomType"               :AlarmCustomType.no,
    "alarmCustomOverPower"          :20,
    "alarmCustomUnderPower"         :20,
    "alarmCustomPercentOverPower"   :20,
    "alarmCustomPercentUnderPower"  :20,
    "alarmCustomPercentOverDegree"  :10,
    "alarmCustomPercentUnderDegree" :10,
    "alarmCustomAmountId"           :0,
    "alarmCustomAmountActivated"    :false,
    "alarmCustomAmountPower"        :200
]

enum Scheduler: String {
    case state             = "scheduleState"
    case powerOnId         = "schedulePowerOnId"
    case powerOffId        = "schedulePowerOffId"
    case powerOnActivated  = "schedulePowerOnActivated"
    case powerOffActivated = "schedulePowerOffActivated"
    case powerOnHour       = "schedulePowerOnHour"
    case powerOffHour      = "schedulePowerOffHour"
    case powerOnMinute     = "schedulePowerOnMinute"
    case powerOffMinute    = "schedulePowerOffMinute"
    case daysOfWeek        = "scheduleDaysOfWeek"
}
let SchedulerDefaultValue: [String: Any] = [
    "scheduleState"             : false,
    "schedulePowerOnId"         : 0,
    "schedulePowerOffId"        : 0,
    "schedulePowerOnActivated"  : false,
    "schedulePowerOffActivated" : false,
    "schedulePowerOnHour"       : 7,
    "schedulePowerOffHour"      : 19,
    "schedulePowerOnMinute"     : 0,
    "schedulePowerOffMinute"    : 0,
    "scheduleDaysOfWeek"        : ""
]

// Line chart things
typealias ChartKeyType = Date
typealias ChartValueType = Double
typealias ChartDataType = OrderedDictionary<ChartKeyType, ChartValueType>
