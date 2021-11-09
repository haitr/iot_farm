//
//  LoginVCViewController.swift
//  sd
//
//  Created by Hai on 12/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit
import WebKit
import RxWebKit
import RxSwift
import RxCocoa
import RxSwiftExt

class LoginVC: BaseVC {

    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var btnReload: UIButton!
    
    var rxDirectURL: PublishSubject<URLRequest>? = nil
    
    let baseURL = URL(string: Network.BasePath)
    
    let apiURL = URL(string: Network.APIPath)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebview()
        requestHandle()
    }
    
    func initWebview() {
        
        rxDirectURL = PublishSubject<URLRequest>()
        
        rxDirectURL?.asObservable()
            .subscribe {
                self.webView.load($0.element!)
            }
            .disposed(by: disposeBag)
        
        btnReload.rx.tap
            .bind {
                self.webView.reload()
            }
            .disposed(by: disposeBag)
        
//        webView.rx.didReceiveServerRedirectForProvisionalNavigation
//            .subscribe {
//                let url = $0.element!.webView.url
//                print("redirect \(url?.absoluteString)")
//            }
//            .disposed(by: disposeBag)
    }
    
    func createReq(path:String, base:URL?) -> URLRequest {
        return URLRequest(url: URL(string: path,
                                   relativeTo: base)!)
    }
    
    func requestHandle() {
        let rxRequest = webView.rx.url.share()
        
        rxRequest
            .subscribe {
                print("URL changed: \(String(describing: $0.element!))")
            }
            .disposed(by: disposeBag)
        
        rxRequest
            .filter {
                $0?.absoluteString.hasSuffix("#/dashboard") ?? false ||
                    $0?.absoluteString.hasSuffix("#/guide") ?? false
            }
            .subscribe {
                print("already log in \($0)")
                // request code
                self.rxDirectURL?.onNext(self.createReq(path: Network.AuthPath, base: self.apiURL))
            }
            .disposed(by: disposeBag)
        
//        rxRequest
//            .filter {
//                $0?.absoluteString.contains("#/login") ?? false
//            }
//            .subscribe {
//                print("log in \($0)")
//            }
//            .disposed(by: disposeBag)
        
        rxRequest
            .map {
                ($0?.absoluteString,
                 $0?.absoluteString.range(of: "(?<=code=).*",
                                          options: .regularExpression))
            }
            .filter { $0.1 != nil }
            .subscribe {
                let (str, range) = $0.element!
                let code = str![range!]
                print("code: \(code)")
                // get access token
                Network.network
                    .getToken(code: String(code),
                              clientSecret: Network.ClientSecret,
                              clientId: Network.ClientId)
                    .subscribe(onNext: { token in
                        Common.common.setAccessToken(token: token)
                    }, onError: { error in
                        print(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        rxRequest
            .filter { $0?.absoluteString.contains("?error=") ?? false }
            .subscribe { Common.common.removeAccessToken() }
            .disposed(by: disposeBag)
        
        Common.common.rxToken()
            .unwrap() //
            .subscribe {
                print("Gained token: \($0)")
                Common.common.setAccessToken(token: $0.element!)
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        Common.common.rxToken()
            .filter { $0 == nil }
            .subscribe {
                print("Login again because token is \($0)")
                // clear cookie
                let date = Date(timeIntervalSince1970: 0)
                WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                        modifiedSince: date,
                                                        completionHandler: { print("Clear done") })
                // redirect
                self.rxDirectURL?.onNext(
                    self.createReq(path: Network.LoginPath,
                                   base: self.baseURL))
            }
            .disposed(by: disposeBag)
    }

}
