//
//  DriverViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/20/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

class DriverViewController: BaseViewController {
    
    var timer: Timer?
    var currentRegion: Region?
    
    override func configureUI() {
        super.configureUI()
        let button = UIButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 50, height: 50))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("again", for: .normal)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        button.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func startOperation() {
        let marker = GMSMarker(position: driverPath[0].coordinate2D)
        marker.title = "moving marker"
        marker.map = self.mapView
        
        currentRegion = tree.nodeFor(value: driverPath[0])?.region
        
        
        if let currentRegion = currentRegion
        {
            publishLocation(at: driverPath[0], region: currentRegion)
        }
        
        var index = 1
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            guard index < driverPath.count else {
                timer.invalidate()
                return
            }
            
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(1)
            marker.position = driverPath[index].coordinate2D
            self.mapView.animate(toLocation:  driverPath[index].coordinate2D)
//            CATransaction.commit()
            
            
            self.checkRegionAndPublish(with: driverPath[index])
            
            index += 1
        }
    }
    
    func checkRegionAndPublish(with coordinate: Coordinate)
    {
        if let currentRegion = currentRegion
        {
            if currentRegion.contains(coordinate)
            {
                publishLocation(at: coordinate, region: currentRegion)
            }
            else
            {
                publishLeaveAction(region: currentRegion)
                self.currentRegion = currentRegion.neighbour(for: coordinate)
                checkRegionAndPublish(with: coordinate)
            }
            
        }
        else
        {
            currentRegion = self.tree.nodeFor(value: coordinate)?.region
            
            if currentRegion != nil {
                checkRegionAndPublish(with: coordinate)
            }
        }
    }
    
    func publishLocation(at coordinate: Coordinate, region: Region)
    {
        MQTTManager.sharedConnection.publish(message: "{\"carId\": 1, \"lat\": \(coordinate.latitude), \"long\": \(coordinate.longitude)}", topic: "tawseel/drivers/\(region.id)")
    }
    
    func publishLeaveAction(region: Region)
    {
        MQTTManager.sharedConnection.publish(message: "{\"carId\": 1, \"action\": \"Left this region\"}", topic: "tawseel/drivers/\(region.id)")
    }
    
    @objc func buttonPressed() {
        timer?.invalidate()
        currentRegion = nil
        startOperation()
    }
}

