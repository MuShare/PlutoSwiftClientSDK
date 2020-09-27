//
//  PlutoUser.swift
//  Pluto
//
//  Created by Meng Li on 2020/09/06.
//  Copyright © 2020 MuShare. All rights reserved.
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

public struct PlutoUser {
    public let id: Int
    public let avatar: String
    public let name: String
    public let bindings: [Binding]
    
    public struct Binding {
        public let loginType: Pluto.LoginType
        public let mail: String?
    }
    
    public var google: Binding? {
        bindings.first { $0.loginType == .google }
    }
    
    public var mail: Binding? {
        bindings.first { $0.loginType == .mail }
    }
    
    public var apple: Binding? {
        bindings.first { $0.loginType == .apple }
    }
    
    public var wechat: Binding? {
        bindings.first { $0.loginType == .wechat }
    }
}

