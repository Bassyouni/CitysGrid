//
//  ViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/2/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

class ViewController: UIViewController {

    // MARK: - variables
    var tree: IntervalTree!
    var mapView: GMSMapView!
    var regions = [Region]()
    var bag = DisposeBag()
    var timer: Timer?
    
    var currentRegion: Region?
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureUI()
        setupGrid()
        setupRegions()
        setupMQTT()
    }
    
    
    // MARK: - UI
    func configureUI() {
        setupMap()
        view.backgroundColor = .purple
        let button = UIButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 50, height: 50))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("again", for: .normal)
        button.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        button.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    }
    
    // MARK: - map
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 25.089694, longitude: 55.256633, zoom: 12)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        view.addSubview(mapView)
    }
    
    func putMarkersOnMap(from coordinates: [[Coordinate]]) {
        for i in 0..<coordinates.count {
            for j in 0..<coordinates[i].count {
                let marker = GMSMarker(position: coordinates[i][j].coordinate2D)
                marker.title = "\(i) \(j)"
                marker.map = self.mapView
            }
        }
    }
    
    func addRegionsPolygons(with grid: [[Coordinate]]) {
        var polygonsPathArray = [GMSMutablePath]()
        let colors: [UIColor] = [UIColor.red, .blue, .magenta, .black, .purple, .cyan, .brown, .darkGray, .orange]

        for i in 0..<grid.count - 1
        {
            for j in 0..<(grid[i].count - 1)
            {
                let path = GMSMutablePath()
                let firstPoint = grid[i][j]
                let secondPoint = grid[i + 1][j]
                let thirdPoint = grid[i + 1][j + 1]
                let fourthPoint = grid[i][j + 1]
                
                path.add( firstPoint.coordinate2D )
                path.add( secondPoint.coordinate2D )
                path.add( thirdPoint.coordinate2D)
                path.add( fourthPoint.coordinate2D )
                
                let edgeCoordinates = EdgeCoordinates([firstPoint, secondPoint, thirdPoint, fourthPoint])
                regions.append(Region(id: j + i, edgeCoordinates: edgeCoordinates, neighbours: []))
                polygonsPathArray.append(path)
            }
        }
        
        for (i , path) in polygonsPathArray.enumerated()
        {
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = colors[i % colors.count].withAlphaComponent(0.2)
            polygon.strokeColor = colors[i % colors.count]
            polygon.strokeWidth = 2
            polygon.map = mapView
        }
        
        
//        putMarkersOnMap(from: [regions.map { $0.centerCoordinate }] )
        
    }
    
    
    // MARK: - MQTT
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
    
    
    // MARK: - Driver Logic
    func startOperation() {
        
        let marker = GMSMarker(position: driverPath[0].coordinate2D)
        marker.title = "moving marker"
        marker.map = self.mapView
        
        currentRegion = tree.nodeFor(value: driverPath[0])?.region
        
        
        if let currentRegion = currentRegion
        {
            publishLocation(at: driverPath[0], region: currentRegion)
        }
        
        var index = 1
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            guard index < driverPath.count else {
                timer.invalidate()
                return
            }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(1)
            marker.position = driverPath[index].coordinate2D
            self.mapView.animate(toLocation:  driverPath[index].coordinate2D)
            CATransaction.commit()
            
           
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
        MQTTManager.sharedConnection.publish(message: "{\"carId\": 1, \"lat\": \(coordinate.latitude), \"long\": \(coordinate.latitude)}", topic: "tawseel/drivers/\(region.id)")
    }
    
    func publishLeaveAction(region: Region)
    {
        MQTTManager.sharedConnection.publish(message: "{\"carId\": 1, \"action\": \"Left this region\"", topic: "tawseel/drivers/\(region.id)}")
    }
    
    // MARK: - action
    @objc func buttonPressed() {
        timer?.invalidate()
        currentRegion = nil
        startOperation()
    }
        
    
}
