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
    
    let data: [String: Any]
    let body: JSON
    let plutoError: PlutoError
    
    init(_ response: AFDataResponse<Any>) {
        Pluto.shared.didReceivedResponse?(response)
        if let value = response.value as? [String: Any] {
            data = value
            #if DEBUG
            let url = response.request?.url?.absoluteString ?? ""
            let requestBody = String(data: response.request?.httpBody ?? Data(), encoding: .utf8) ?? ""
            print("\(Date()) Response for \(url)\n requestBody: \(requestBody)\n response: \(value)")
            #endif
        } else {
            data = [:]
        }
        if let result = data["body"] as? [String: Any] {
            body = JSON(result)
        } else {
            body = JSON()
        }
        if !data.isEmpty, let error = data["error"] as? [String: Any], let code = error["code"] as? Int {
            plutoError = PlutoError(rawValue: code) ?? .badRequest
        } else {
            plutoError = .badRequest
        }
        
        // Handle global error.
        switch plutoError {
        case .invalidRefreshToken:
            DefaultsManager.shared.clear()
            Pluto.shared.state = .invalidRefreshToken
        default:
            break
        }
    }
    
    func statusOK() -> Bool {
        guard !data.isEmpty, let status = data["status"] as? String else {
            return false
        }
        return status == "ok"
    }
    
    func getBody() -> JSON {
        return body
    }
    
    func getError() -> PlutoError {
        return plutoError
    }
    
}

public enum PlutoError: Int, Error {
    case unknown = -99999
    case badRequest = -99998
    case parseError = -99997
    case avatarBase64GenerateError = 901
    case appleSigninAuthorizationParseError = 902
    case notSignin = 1001
    case mailIsAlreadyRegister = 2001
    case mailIsNotExist = 2002
    case mailIsNotVerified = 2003
    case mailAlreadyVerified = 2004
    case userIdNotExist = 2005
    case userIdExist = 2006
    case bindAlreadyExist = 2007
    case bindNotExist = 2008
    case passwordNotSet = 2009
    case unbundNotAllow = 2010
    case invalidPassword = 3001
    case invalidRefreshToken = 3002
    case invalidJWTToekn = 3003
    case invalidGoogleIDToken = 3004
    case invalidWechatCode = 3005
    case invalidAvatarFormat = 3006
    case invalidAppleIDToken = 3007
    case jwtTokenExpired = 3008
    case invalidAccessToken = 3009
    case invalidApplication = 3010
    case refreshTokenExpired = 3011
}
