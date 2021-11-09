//
//  Network.swift
//  mdm_ios_swift
//
//  Created by Hai on 06/04/2017.
//  Copyright © 2017 AHope. All rights reserved.
//

import UIKit
import RxAlamofire
import RxSwift
import Alamofire

final class Network {
    // app fixed id, create from outside of the app
    static let ClientId = "testid2"
    static let ClientSecret = "testsecret"
    
    // URL
    static let RedirectPath = "about:blank"
    static let BasePath = "https://www.testxtra.sensorjs.com:20443"
    static let APIPath = "https://api.testxtra.sensorjs.com:20443"
    static let LoginPath = "#/login"
    static let AuthPath = "/v1/oauth2/authorize?response_type=code&client_id=\(ClientId)&redirect_uri=about:blank"
    static let TokenAPI = "/v1/oauth2/token"
    static let UserInfoAPI = "/users/me"
    static let AllRulesAPI = "/rules"
    static let AllGatewaysAPI = "/gateways?embed=sensors&sensors[embed]=series"
    static let GatewayAPI = "/gateways/%@"
    static let StatisticAPI = "/v2/gateways/%@/sensors/%@"
    
    // Defined sensor's data queries
    static let locationSensorParams = ["embed": "series",
                                       "series[interval]": "24h",
                                       "series[intervalFunc]": "last"]
    static let commonSensorParams = ["embed": "series",
                                     "series[interval]": "24h",
                                     "series[intervalFunc]": "avg"]
    
    // Can't init is singleton
    private init() {
        
    }
    
    //MARK: Shared Instance
    
    static let network: Network = Network()
    
    let disposeBag = DisposeBag()
    
}

extension Network {
    
    func request(method: Alamofire.HTTPMethod, url: String, parameters: [String:String]?, headers: [String:String]) -> Observable<Any> {
        return Observable<Any>.create {observer in
            let rxReq =
                RxAlamofire
                    .requestJSON(method,
                                 url,
                                 parameters: parameters,
                                 encoding: URLEncoding.default,
                                 headers: headers)
                    .catchError { error in
                        print(error)
                        return Observable.never()
                    }
                    .subscribe {
                        if let ele = $0.element {
                            let (res, data) = ele
                            if let json = data as? [String: Any] {
                                // Check error message
                                switch res.statusCode / 100 {
                                case 4: // 4xx error
                                    let caused = json["message"] as? String
                                    observer.onError(NSError(domain: caused ?? "unknown", code: res.statusCode))
                                    break
                                default:
                                    observer.onNext(json)
                                    observer.onCompleted()
                                    break
                                }
                            } else if let json = data as? [Any] {
                                // Array result, absolutely no error
                                observer.onNext(json)
                                observer.onCompleted()
                            } else {
                                observer.onError(NSError(domain: "Cannot read response data", code: -1))
                            }
                        } else {
                            observer.onError(NSError(domain: "Cannot read response data", code: -1))
                        }
            }
            
            return Disposables.create([rxReq])
        }
    }
    
    func get(url: String, parameters: [String:String]?, headers: [String:String]) -> Observable<Any> {
        print("Get: \(url)")
        return request(method: .get, url: url, parameters: parameters, headers: headers)
    }
    
    func post(url: String, parameters: [String:String]?, headers: [String:String]) -> Observable<Any> {
        print("Post: \(url)")
        return request(method: .post, url: url, parameters: parameters, headers: headers)
    }
    
    func delete(url: String, parameters: [String:String]?, headers: [String:String]) -> Observable<Any> {
        print("Delete: \(url)")
        return request(method: .delete, url: url, parameters: parameters, headers: headers)
    }
    
}

extension Network { // API
    // Get user info
    func getUserInfo() -> Observable<UserInfo> {
        if let token = Common.common.accessToken() {
            let url = Network.APIPath + Network.UserInfoAPI
            let headers = commonHeader(token: token)
            return get(url: url, parameters: nil, headers: headers)
                    .map { UserInfo(from: $0) }
        } else {
            return Observable.error(NSError(domain: "Nil token", code: -1, userInfo: nil))
        }
    }
    
    // Exchange code with access token
    func getToken(code: String, clientSecret: String, clientId: String) -> Observable<String> {
        
        print("Request token with code:\(code) id:\(clientId) secret:\(clientSecret)")
        
        let url = Network.APIPath + Network.TokenAPI
        
        let param = ["code": code,
                     "client_id": clientId,
                     "client_secret": clientSecret,
                     "redirect_uri": Network.RedirectPath,
                     "grant_type": "authorization_code"]
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        return post(url: url, parameters: param, headers: headers)
                .map { ($0 as! [String: Any])["access_token"] as! String }
    }
    
    func getAllRules() -> Observable<Any> {
        if let token = Common.common.accessToken() {
            let url = Network.APIPath + Network.AllRulesAPI
            let headers = commonHeader(token: token)
            return get(url: url, parameters: nil, headers: headers)
        }
        return Observable.error(NSError(domain: "Nil token", code: -1, userInfo: nil))
    }
    
    func getAllGateways() -> Observable<Any> {
        if let token = Common.common.accessToken() {
            let url = Network.APIPath + Network.AllGatewaysAPI
            let headers = commonHeader(token: token)
            return get(url: url, parameters: nil, headers: headers)
        }
        return Observable.error(NSError(domain: "Nil token", code: -1, userInfo: nil))
    }
    
    func deleteGateway(gateway: Gateway, index: Int) -> Observable<Int> {
        return Observable.deferred {
            if let token = Common.common.accessToken(),
                let id = gateway.id{
                let url = Network.APIPath + String(format: Network.GatewayAPI, id)
                let headers = self.commonHeader(token: token)
                return self.delete(url: url, parameters: nil, headers: headers)
                    .flatMap { _ in Observable.just(index) }
            } else {
                return Observable.error(NSError(domain: "Nil token", code: -1, userInfo: nil))
            }
        }
    }
    
    func getStatisticData(sensor: Sensor,
                          startDate: Date,
                          endDate: Date,
                          params: [String:String]) -> Observable<Any> {
        if let token = Common.common.accessToken() {
            let url = Network.APIPath + String(format: Network.StatisticAPI, sensor.deviceId, sensor.id)
            let headers = commonHeader(token: token)
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.sss'Z'"
            var params = params
            params["series[dataStart]"] = df.string(from: startDate)
            params["series[dataEnd]"] = df.string(from: endDate)
            return get(url: url, parameters: params, headers: headers)
        } else {
            return Observable.error(NSError(domain: "Nil token", code: -1, userInfo: nil))
        }
    }
    
}

extension Network { // private functions
    
    private func saveDirectoryURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    private func commonHeader(token: String) -> [String:String] {
        return ["authorization": "Bearer \(token)", "cache-control": "no-cache"]
    }
}
