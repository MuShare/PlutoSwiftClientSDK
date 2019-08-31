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

import SwiftyUserDefaults

extension DefaultsKeys {
    static let jwt = DefaultsKey<String?>("org.mushare.pluto.jwt")
    static let refreshToken = DefaultsKey<String?>("org.mushare.pluto.refreshToken")
    static let expire = DefaultsKey<Int>("org.mushare.pluto.exipre", defaultValue: 0)
    static let userId = DefaultsKey<Int?>("org.mushare.pluto.userId")
    static let username = DefaultsKey<String?>("org.mushare.pluto.username")
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

    var username: String? {
        set {
            Defaults[.username] = newValue
        }
        get {
            return Defaults[.username]
        }
    }

    var avatar: String? {
        set {
            Defaults[.avatar] = newValue
        }
        get {
            return Defaults[.avatar]
        }
    }
    
}
