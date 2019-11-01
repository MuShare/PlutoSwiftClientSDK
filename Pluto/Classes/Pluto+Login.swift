//
//  Pluto+Login.swift
//  Pluto
//
//  Created by Meng Li  on 2019/11/01.
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
    
    public func logout() {
        DefaultsManager.shared.clear()
        state = .notSignin
    }
    
}
