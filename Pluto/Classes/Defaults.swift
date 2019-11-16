//
//  Defaults.swift
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

import SwiftyJSON
import SwiftyUserDefaults

extension DefaultsKeys {
    static let jwt = DefaultsKey<String?>("org.mushare.pluto.jwt")
    static let refreshToken = DefaultsKey<String?>("org.mushare.pluto.refreshToken")
    static let expire = DefaultsKey<Int>("org.mushare.pluto.exipre", defaultValue: 0)
    static let userId = DefaultsKey<Int?>("org.mushare.pluto.userId")
    static let mail = DefaultsKey<String?>("org.mushare.pluto.mail")
    static let name = DefaultsKey<String?>("org.mushare.pluto.name")
    static let avatar = DefaultsKey<String?>("org.mushare.pluto.avatar")
}

class DefaultsManager {

    static let shared = DefaultsManager()
    
    private init() {}
    
    var jwt: String? {
        set {
            Defaults[.jwt] = newValue
        }
        get {
            return Defaults[.jwt]
        }
    }
    
    var refreshToken: String? {
        set {
            Defaults[.refreshToken] = newValue
        }
        get {
            return Defaults[.refreshToken]
        }
    }
    
    var expire: Int {
        set {
            Defaults[.expire] = newValue
        }
        get {
            return Defaults[.expire]
        }
    }
    
    var userId: Int? {
        set {
            Defaults[.userId] = newValue
        }
        get {
            return Defaults[.userId]
        }
    }

    var user: PlutoUser? {
        get {
            guard
                let userId = Defaults[.userId],
                let mail = Defaults[.mail],
                let name = Defaults[.name],
                let avatar = Defaults[.avatar]
            else {
                return nil
            }
            return PlutoUser(id: userId, mail: mail, avatar: avatar, name: name)
        }
        set {
            Defaults[.userId] = newValue?.id
            Defaults[.mail] = newValue?.mail
            Defaults[.name] = newValue?.name
            Defaults[.avatar] = newValue?.avatar
        }
    }
    
    func updateJwt(_ jwt: String) -> Bool {
        let parts = jwt.split(separator: ".").map(String.init)
        guard parts.count == 3, let restoreString = parts[1].base64Decoded() else {
            return false
        }
        
        let user = JSON(parseJSON: restoreString)
        guard
            let userId = user["userId"].int,
            let expire = user["expire_time"].int
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
        user = nil
    }
    
}
