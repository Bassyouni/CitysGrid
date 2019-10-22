//
//  RegionShowerViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/22/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps

class RegionShowerViewController: BaseViewController {
    
    let coordinates: [Coordinate]
    
    init(coordinates: [Coordinate]) {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = "Region"
        
        self.setupGridWithEdgeCoordinates(coordinates)
        fitMapToCoordinates(coordinates)
    }
    
    override func setupMQTT() {
        
    }
    
    override func setupRegions() {
        
    }
    

    
}
