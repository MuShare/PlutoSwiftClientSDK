//
//  AppDelegate.swift
//  MuShare-Login-Swift-SDK
//
//  Created by Meng Li on 06/11/2019.
//  Copyright (c) 2019 MuShare. All rights reserved.
//

import UIKit
import PlutoSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Pluto.shared.setup(server: "https://staging.easyjapanese-api-gateway.mushare.cn/pluto-master", appId: "org.mushare.easyjapanese")
        return true
    }
    
}

