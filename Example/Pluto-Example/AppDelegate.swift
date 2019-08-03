//
//  AppDelegate.swift
//  MuShare-Login-Swift-SDK
//
//  Created by Meng Li on 06/11/2019.
//  Copyright (c) 2019 MuShare. All rights reserved.
//

import UIKit
import Pluto

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MuShareLogin.setup(server: "https://pluto.mushare.cn", sdkSecret: "8d4f392a-853e-43eb-a5e1-ff05fb32d3df")
        return true
    }
    
}

