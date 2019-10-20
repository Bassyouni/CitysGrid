//
//  BaseViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/20/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

class BaseViewController: UIViewController {
    
    var tree: IntervalTree!
    var mapView: GMSMapView!
    var regions = [Region]()
    
    let colors: [UIColor] = [UIColor.red, .blue, .magenta, .black, .purple, .cyan, .brown, .darkGray, .orange]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
