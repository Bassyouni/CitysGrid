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
    var bag = DisposeBag()
    
    let colors: [UIColor] = [UIColor.red, .blue, .magenta, .black, .purple, .cyan, .brown, .darkGray, .orange]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupGrid()
        setupRegions()
        setupMQTT()
    }
    
    func configureUI() {
        
    }
    
    func setupMQTT() {
        MQTTManager.sharedConnection.connect()
        MQTTManager.sharedConnection.connectionStatus
            .retry()
            .subscribe(onNext: { (isConnected) in
                if isConnected
                {
                    self.startOperation()
                }
            }, onError: { (error) in
                print(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func startOperation() {
        
    }
    
    
}
