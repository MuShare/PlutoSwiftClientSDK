//
//  Pluto+Token.swift
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

    public func getAccessToken(isForceRefresh: Bool = false, completion: @escaping (String?) -> Void) {
        let expire = DefaultsManager.shared.expire
        guard
            !isForceRefresh,
            let accessToken = DefaultsManager.shared.accessToken,
            expire - Int(Date().timeIntervalSince1970) > 30
        else {
            refreshAccessToken(completion: completion)
            return
        }
        completion(accessToken)
    }
    
    func refreshAccessToken(completion: @escaping (String?) -> Void) {
        if isRefreshingAccessToken {
            refreshAccessTokenCompletions.append(completion)
            return
        }
        guard let refreshToken = DefaultsManager.shared.refreshToken else {
            refreshAccessTokenCompletions.forEach {
                $0(nil)
            }
            refreshAccessTokenCompletions.removeAll()
            isRefreshingAccessToken = false
            return
        }
        refreshAccessTokenCompletions.append(completion)
        isRefreshingAccessToken = true
        
        AF.request(
            url(from: "/v1/token/refresh"),
            method: .post,
            parameters: [
                "refresh_token": refreshToken,
                "app_id": appId
            ],
            encoding: JSONEncoding.default
        ).responseJSON { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let response = PlutoResponse($0)
            if response.statusOK() {
                let body = response.getBody()
                guard
                    let accessToken = body["access_token"].string,
                    DefaultsManager.shared.updateAccessToken(accessToken),
                    let refreshToken = body["refresh_token"].string
                else {
                    self.refreshAccessTokenCompletions.forEach {
                        $0(nil)
                    }
                    return
                }
                DefaultsManager.shared.refreshToken = refreshToken
                self.refreshAccessTokenCompletions.forEach {
                    $0(accessToken)
                }
            } else {
                self.refreshAccessTokenCompletions.forEach {
                    $0(nil)
                }
            }
            self.refreshAccessTokenCompletions.removeAll()
            self.isRefreshingAccessToken = false
        }
    }
    
    public func getHeaders(completion: @escaping (HTTPHeaders?) -> Void) {
        getAccessToken {
            guard let jwt = $0 else {
                completion(nil)
                return
            }
            var headers = self.commonHeaders
            headers.add(name: "Authorization", value: "jwt " + jwt)
            completion(headers)
        }
    }
    
    public func getScopes(completion: @escaping ([String]) -> Void) {
        getAccessToken {
            guard let jwt = $0 else {
                completion([])
                return
            }
            completion(jwt.scopes)
        }
    }
    
}
