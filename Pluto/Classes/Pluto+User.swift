//
//  Pluto+User.swift
//  Pluto
//
//  Created by Meng Li  on 2019/01/01.
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
    
    public func myInfo(success: @escaping (PlutoUser) -> Void, error: ErrorCompletion? = nil) {
       guard let jwt = DefaultsManager.shared.jwt else {
           error?(PlutoError.notSignin)
           return
       }

       AF.request(
           url(from: "api/user/info/me"),
           method: .get,
           headers: [
               "Authorization": "jwt " + Data(jwt.utf8).base64EncodedString()
           ]
       ).responseJSON {
           let response = PlutoResponse($0)
           if response.statusOK() {
               let result = response.getBody()
               let user = PlutoUser(
                   id: result["id"].intValue,
                   mail: result["mail"].stringValue,
                   avatar: result["avatar"].stringValue,
                   name: result["name"].stringValue
               )
               DefaultsManager.shared.user = user
               success(user)
           } else {
               error?(response.errorCode())
           }
       }
   }
    
}
