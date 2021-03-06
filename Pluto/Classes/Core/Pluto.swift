//
//  Pluto.swift
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

final public class Pluto {
    
    public typealias ErrorCompletion = (PlutoError) -> Void
    
    public enum State {
        case notSignIn
        case loading
        case signIn
        case invalidRefreshToken
    }
    
    public static let shared = Pluto()
    
    var server: String = ""
    var appId: String = ""
    var isWeChatInstalled = false
    
    var stateObserver: ((State) -> Void)?
    var state: State = DefaultsManager.shared.isTokenNil ? .notSignIn : .signIn {
        didSet {
            stateObserver?(state)
        }
    }
    
    lazy var commonHeaders: HTTPHeaders = {
        // zh-Hans-JP -> zh-Hans
        // zh-Hant-CN -> zh-Hant
        // en-US      -> en-US
        // en         -> en
        let preferredLanguageCode = Locale.preferredLanguages.first?
            .components(separatedBy: "-")
            .prefix(2)
            .joined(separator: "-")
        return HTTPHeaders(["Accept-Language": preferredLanguageCode ?? "en"])
    }()
    
    let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
    var isRefreshingAccessToken = false
    var refreshAccessTokenCompletions: [(String?) -> Void] = []
    
    private init() {}
    
    public var didReceivedResponse: ((AFDataResponse<Any>) -> Void)? = nil
    
    func url(from relativeUrl: String) -> String {
        if server.last == "/" {
            return String(server.dropLast()) + relativeUrl
        }
        return server + relativeUrl
    }
    
    public func setup(server: String, appId: String, isWeChatInstalled: Bool = false) {
        self.server = server
        self.appId = appId
        self.isWeChatInstalled = isWeChatInstalled
    }
    
    public func observeState(observer: ((State) -> Void)?) {
        stateObserver = observer
        stateObserver?(state)
    }
    
    public func currentState() -> Pluto.State {
        return state
    }
    
}

extension Pluto {
    public enum LoginType: String {
        case mail
        case apple
        case google
        case wechat
        
        var identifier: String {
            rawValue
        }
        
        static func from(identifier: String) -> LoginType? {
            return LoginType(rawValue: identifier)
        }
    }
}
