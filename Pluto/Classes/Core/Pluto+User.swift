//
//  Pluto+User.swift
//  Pluto
//
//  Created by Meng Li on 2019/01/01.
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
    
    public func myInfo(isForceRefresh: Bool = false, success: @escaping (PlutoUser) -> Void, error: ErrorCompletion? = nil) {
        if !isForceRefresh, let user = DefaultsManager.shared.user {
            success(user)
            return
        }
        let requestUrl = url(from: "/v1/user/info")
        getHeaders {
            AF.request(requestUrl, method: .get, headers: $0).responseJSON {
                let response = PlutoResponse($0)
                if response.statusOK() {
                    DefaultsManager.shared.infoJSONString = response.getBody().description
                    guard let user = DefaultsManager.shared.user else {
                        error?(PlutoError.parseError)
                        return
                    }
                    DefaultsManager.shared.userId = user.id
                    success(user)
                } else {
                    if let user = DefaultsManager.shared.user {
                        success(user)
                    } else {
                        error?(response.getError())
                    }
                }
            }
        }
    }
    
    public func updateUserId(userId: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        updateInfo(parameters: ["user_id": userId], success: success, error: error)
    }
    
    public func updateName(name: String, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        updateInfo(parameters: ["name": name], success: success, error: error)
    }
    
    public func uploadAvatar(image: UIImage, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        guard let base64 = image.base64() else {
            error?(PlutoError.avatarBase64GenerateError)
            return
        }
        updateInfo(parameters: ["avatar": base64], success: success, error: error)
    }
    
    private func updateInfo(parameters: Parameters, success: @escaping () -> Void, error: ErrorCompletion? = nil) {
        let requestUrl = url(from: "/v1/user/info")
        getHeaders {
            AF.request(
                requestUrl,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: $0
            ).responseJSON {
                let response = PlutoResponse($0)
                if response.statusOK() {
                    success()
                } else {
                    error?(response.getError())
                }
            }
        }
    }
    
}
