//
//  AppDelegate.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/2/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

#if Driver
let isDriverApp = true
#else
let isDriverApp = false
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let key = "AIzaSyBsNv5UAwJ7a0VFTpM_0I7jyAi-aXbTDVE"
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
        
        window = UIWindow()
        
        
        
        if isDriverApp {
            window?.rootViewController = DriverViewController()
        }
        else {
            window?.rootViewController = CustomerViewController()
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
}
