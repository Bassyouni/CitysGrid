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
        setupGridWithEdgeCoordinates([Coordinate(latitude: 24.604503, longitude: 54.844086),
                                      Coordinate(latitude: 24.138950, longitude: 54.816490),
                                      Coordinate(latitude: 24.173921, longitude: 54.256488),
                                      Coordinate(latitude: 24.624247, longitude: 54.285306)])
        setupRegions()
        setupMQTT()
    }
    
    func configureUI() {
        view.backgroundColor = .purple
        setupMap()
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 24.96334, longitude: 55.477316, zoom: 12)
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
        
        addNeighnours(rowCount: (grid.first?.count ?? 0) - 1 )
        
        
        
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
