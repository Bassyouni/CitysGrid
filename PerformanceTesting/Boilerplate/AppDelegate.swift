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
    
    // Complete the formingMagicSquare function below.
    func formingMagicSquare(s: [[Int]]) -> Int {
        
        var matrix = s
        var errorScore = 0
        var cornersDict = Dictionary<Int, (Int, Int)>()
        cornersDict[matrix[0][0]] = (0,0)
        cornersDict[matrix[0][2]] = (0,2)
        cornersDict[matrix[2][0]] = (2,0)
        cornersDict[matrix[2][2]] = (2,2)
        
        let cornersActualDict = [4: 6, 6: 4, 2: 8, 8: 2]
        let desposeCorner = ["00": (2,2), "22": (0,0), "20": (0,2), "02": (2,0)]
        let edges = [12: 3, 14: 1, 6:9, 8:7]
        
        if matrix[1][1] != 5
        {
            errorScore += abs(matrix[1][1] - 5)
           matrix[1][1] = 5
        }
        
        for (key, value) in cornersActualDict
        {
            if let index = cornersDict[key]
            {
                if let desposeIndex = desposeCorner["\(index.0)\(index.1)"]
                {
                    if matrix[desposeIndex.0][desposeIndex.1] != value
                    {
                        errorScore += abs(matrix[desposeIndex.0][desposeIndex.1] - value)
                        matrix[desposeIndex.0][desposeIndex.1] = value
                    }
                }
            }
        }
        
        if let middleNumber = edges[(matrix[0][0] + matrix[0][2])], middleNumber == matrix[0][1]
        {
            errorScore += abs(matrix[0][1] - middleNumber)
            matrix[0][1] = middleNumber
        }
        
        if let middleNumber = edges[(matrix[0][0] + matrix[2][0])], middleNumber == matrix[1][0]
        {
            errorScore += abs(matrix[1][0] - middleNumber)
            matrix[1][0] = middleNumber
        }
        
        if let middleNumber = edges[(matrix[0][2] + matrix[2][2])], middleNumber == matrix[1][2]
        {
            errorScore += abs(matrix[1][2] - middleNumber)
            matrix[1][2] = middleNumber
        }
        
        if let middleNumber = edges[(matrix[2][0] + matrix[2][2])], middleNumber == matrix[2][1]
        {
            errorScore += abs(matrix[2][1] - middleNumber)
            matrix[2][1] = middleNumber
        }
        
        
        
        return errorScore
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(formingMagicSquare(s: [[4,8,2], [4,5,7], [6,1,6]])) // 4
        print(formingMagicSquare(s: [[4,9,2], [3,5,7], [8,1,5]])) // 1
        print(formingMagicSquare(s: [[5,3,4], [1,5,8], [6,4,2]])) // 7

        let key = "AIzaSyBsNv5UAwJ7a0VFTpM_0I7jyAi-aXbTDVE"
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
        
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "Helvetica-Bold", size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
        
        window = UIWindow()
        
        
        if isDriverApp {
            window?.rootViewController = UINavigationController(rootViewController: DriverViewController())
        }
        else {
            window?.rootViewController = UINavigationController(rootViewController: CustomerViewController())
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
}
