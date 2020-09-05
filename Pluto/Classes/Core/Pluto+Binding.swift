//
//  Pluto+Binding.swift
//  Alamofire
//
//  Created by Meng Li on 2020/9/5.
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

extension Pluto {
    
    public enum LoginType {
        case mail
        case apple
        case google
        
        var identifier: String {
            switch self {
            case .mail: return "mail"
            case .apple: return "apple"
            case .google: return "google"
            }
        }
    }
    
    public func binding(type: LoginType, authString: String, success: (() -> Void)? = nil, error: ErrorCompletion? = nil) {
        var parameters = [
            "type": type.identifier
        ]
        switch type {
        case .mail:
            parameters["mail"] = authString
        case .apple:
            parameters["code"] = authString
        case .google:
            parameters["id_token"] = authString
        }
        let requestUrl = url(from: "/v1/user/binding")
        getHeaders {
            AF.request(
                requestUrl,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: $0
            ).responseJSON {
                let response = PlutoResponse($0)
                if response.statusOK() {
                    success?()
                } else {
                    error?(response.errorCode())
                }
            }
        }
    }
    
    public func unbinding(type: LoginType, success: (() -> Void)? = nil, error: ErrorCompletion? = nil) {
        let requestUrl = url(from: "/v1/user/unbinding")
        getHeaders {
            AF.request(
                requestUrl,
                method: .post,
                parameters: [
                    "type": type.identifier
                ],
                encoding: JSONEncoding.default,
                headers: $0
            ).responseJSON {
                let response = PlutoResponse($0)
                if response.statusOK() {
                    success?()
                } else {
                    error?(response.errorCode())
                }
            }
        }
    }
    
}

