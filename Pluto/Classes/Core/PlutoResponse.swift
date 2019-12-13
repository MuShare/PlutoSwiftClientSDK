//
//  PlutoResponse.swift
//  Pluto
//
//  Created by Meng Li on 2019/08/03.
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

struct PlutoResponse {

    var data: [String: Any] = [:]
    
    init(_ response: AFDataResponse<Any>) {
        if let value = response.value as? [String: Any] {
            data = value
            print(value)
        }
    }
    
    func statusOK() -> Bool {
        guard !data.isEmpty, let status = data["status"] as? String else {
            return false
        }
        return status == "ok"
    }
    
    func getBody() -> JSON {
        guard let result = data["body"] as? [String: Any] else {
            return JSON()
        }
        return JSON(result)
    }
    
    func errorCode() -> PlutoError {
        guard
            !data.isEmpty,
            let error = data["error"] as? [String: Any],
            let code = error["code"] as? Int
        else {
            return .badRequest
        }
        return PlutoError(rawValue: code) ?? .badRequest
    }
    
}

public enum PlutoError: Int, Error {
    case unknown = -99999
    case badRequest = -99998
    case parseError = -99997
    case notSignin = 1001
    case mailIsAlreadyRegister = 2001
    case mailIsNotExsit = 2002
    case mailIsNotVerified = 2003
    case mailAlreadyVerified = 2004
    case invalidPassword = 3001
    case invalidRefreshToken = 3002
    case invalidJWTToekn = 3003
}
