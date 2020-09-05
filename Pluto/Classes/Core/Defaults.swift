//
//  Defaults.swift
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

import SwiftyJSON
import SwiftyUserDefaults

extension DefaultsKeys {
    var jwt: DefaultsKey<String?> { .init("org.mushare.pluto.jwt") }
    var refreshToken: DefaultsKey<String?> { .init("org.mushare.pluto.refreshToken") }
    var expire: DefaultsKey<Int> { .init("org.mushare.pluto.exipre", defaultValue: 0) }
    var userId: DefaultsKey<Int?> { .init("org.mushare.pluto.userId") }
    var infoJSONString: DefaultsKey<String?> { .init("org.mushare.pluto.info") }
}

class DefaultsManager {

    static let shared = DefaultsManager()
    
    private init() {}
    
    var jwt: String? {
        get {
            Defaults.jwt
        }
        set {
            Defaults.jwt = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            Defaults.refreshToken
        }
        set {
            Defaults.refreshToken = newValue
        }
    }
    
    var expire: Int {
        get {
            Defaults.expire
        }
        set {
            Defaults.expire = newValue
        }
    }
    
    var userId: Int? {
        get {
            Defaults.userId
        }
        set {
            Defaults.userId = newValue
        }
    }
    
    var infoJSONString: String? {
        get {
            Defaults.infoJSONString
        }
        set {
            Defaults.infoJSONString = newValue
        }
    }

    var user: PlutoUser? {
        guard let jsonString = infoJSONString else {
            return nil
        }
        let info = JSON(jsonString)
        return PlutoUser(
            id: info["sub"].intValue,
            avatar: info["avatar"].stringValue,
            name: info["name"].stringValue,
            bindings: info["bindings"].arrayValue.compactMap {
                guard let loginType = Pluto.LoginType.from(identifier: $0["login_type"].stringValue) else {
                    return nil
                }
                return PlutoUser.Binding(
                    loginType: loginType,
                    mail: $0["mail"].string
                )
            }
        )

    }
    
    func updateJwt(_ jwt: String) -> Bool {
        let parts = jwt.split(separator: ".").map(String.init)
        guard parts.count == 3, let restoreString = parts[1].base64Decoded else {
            return false
        }
        
        let user = JSON(parseJSON: restoreString)
        guard
            let userId = user["sub"].int,
            let expire = user["exp"].int
        else {
            return false
        }
        self.userId = userId
        self.expire = expire
        self.jwt = jwt
        return true
    }
    
    func clear() {
        jwt = nil
        refreshToken = nil
        expire = 0
        userId = nil
        infoJSONString = nil
    }
    
}
