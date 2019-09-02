//
//  Pluto.swift
//  Pluto
//
//  Created by Meng Li  on 2019/08/03.
//  Copyright © 2018 MuShare. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Alamofire
import SwiftyJSON

public struct PlutoUser {
    let id: Int
    let mail: String
    let avatar: String
    let name: String
}

final public class Pluto {
    
    public typealias ErrorCompletion = (PlutoError) -> Void
    
    public enum State {
        case notSignin
        case loading
        case signin
    }
    
    public static let shared = Pluto()
    
    private var server: String = ""
    private var appId: String = ""
    
    private var stateObserver: ((State) -> Void)?
    private var state: State = .loading {
        didSet {
            stateObserver?(state)
        }
    }
    
    private let devideId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
    private init() {}
   
    private func url(from relativeUrl: String) -> String {
        return server + "/" + relativeUrl
    }
    
    public func setup(server: String, appId: String) {
        self.server = server
        self.appId = appId
        
        refreshToken { [unowned self] in
            guard $0 != nil else {
                self.state = .notSignin
                return
            }
            self.state = .signin
        }
    }
    
    public func observeState(observer: ((State) -> Void)?) {
        stateObserver = observer
    }

}

extension Pluto {

    public func registerByEmail(address: String, password: String, name: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        AF.request(
            url(from: "api/user/register"),
            method: .post,
            parameters: [
                "mail": address,
                "password": password,
                "name": name
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
    public func resendValidationEmail(address: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        AF.request(
            url(from: "api/user/register/verify/mail"),
            method: .post,
            parameters: [
                "mail": address
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
    public func loginWithEmail(address: String, password: String, success: (() -> Void)? = nil, error: ErrorCompletion? = nil) {
        AF.request(
            url(from: "api/user/login"),
            method: .post,
            parameters: [
                "mail": address,
                "password": password,
                "device_id": devideId,
                "app_id": appId
//                "version": UIDevice.current.systemVersion,
//                "language": Bundle.main.preferredLocalizations[0].components(separatedBy: "-")[0]
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON { [weak self] in
            guard let `self` = self else {
                error?(PlutoError.unknown)
                return
            }
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                guard
                    let refreshToken = body["refresh_token"].string,
                    let jwt = body["jwt"].string
                else {
                    error?(PlutoError.parseError)
                    return
                }
                
                DefaultsManager.shared.refreshToken = refreshToken
                DefaultsManager.shared.jwt = jwt
                
                let parts = jwt.split(separator: ".").map(String.init)
                guard
                    parts.count == 3, let restoreData = Data(base64Encoded: parts[1]),
                    let restoreString = String(data: restoreData, encoding: .utf8)
                else {
                    error?(PlutoError.parseError)
                    return
                }
                
                let user = JSON(parseJSON: restoreString)
                guard
                    let userId = user["userId"].int,
                    let expire = user["expire_time"].int
                else {
                    error?(PlutoError.parseError)
                    return
                }
                DefaultsManager.shared.userId = userId
                DefaultsManager.shared.expire = expire
                self.state = .signin
                success?()
            } else {
                error?(response.errorCode())
            }
        }
    }
    
    public func resetPassword(address: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        AF.request(
            url(from: "api/user/password/reset/mail"),
            method: .post,
            parameters: [
                "mail": address
            ],
            encoding: JSONEncoding.default,
            headers: nil
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                success()
            } else {
                error?(response.errorCode())
            }
        }
    }

    public func myInfo(success: @escaping (PlutoUser) -> Void, error: ErrorCompletion? = nil) {
        guard let jwt = DefaultsManager.shared.jwt else {
            error?(PlutoError.notSignin)
            return
        }

        AF.request(
            url(from: "api/user/info/me"),
            method: .get,
            headers: [
                "Authorization": "jwt " + Data(jwt.utf8).base64EncodedString()
            ]
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                let result = response.getBody()
                let user = PlutoUser(
                    id: result["id"].intValue,
                    mail: result["mail"].stringValue,
                    avatar: result["avatar"].stringValue,
                    name: result["name"].stringValue
                )
                DefaultsManager.shared.user = user
                success(user)
            } else {
                print(response.errorCode())
                error?(response.errorCode())
            }
        }
    }
    
}

extension Pluto {
    
    public func getToken(completion: @escaping (String?) -> Void) {
        let expire = DefaultsManager.shared.expire
        guard
            let jwt = DefaultsManager.shared.jwt,
            expire - Int(Date().timeIntervalSince1970) > 5 * 60
        else {
            refreshToken(completion: completion)
            return
        }
        completion(jwt)
    }
    
    private func refreshToken(completion: @escaping (String?) -> Void) {
        guard
            let userId = DefaultsManager.shared.userId,
            let refreshToken = DefaultsManager.shared.refreshToken
        else {
            completion(nil)
            return
        }
        AF.request(
            url(from: "api/auth/refresh"),
            method: .post,
            parameters: [
                "refresh_token": refreshToken,
                "user_id": userId,
                "device_id": devideId,
                "app_id": appId
            ],
            encoding: JSONEncoding.default
        ).responseJSON {
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                guard let jwt = body["jwt"].string else {
                    completion(nil)
                    return
                }
                DefaultsManager.shared.jwt = jwt
                completion(jwt)
            }
        }
    }
    
}
