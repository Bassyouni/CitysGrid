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
    
    // MARK: - variables
    var tree: IntervalTree!
    var mapView: GMSMapView!
    var regions = [Region]()
    var bag = DisposeBag()
    
    let colors: [UIColor] = [UIColor.red, .blue, .magenta, .black, .purple, .cyan, .brown, .darkGray, .orange]
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureUI()
        if !(self is RegionShowerViewController) {
//            let aboDuhbiCoordinates = [Coordinate(latitude: 24.604503, longitude: 54.844086),
//                               Coordinate(latitude: 24.138950, longitude: 54.816490),
//                               Coordinate(latitude: 24.173921, longitude: 54.256488),
//                               Coordinate(latitude: 24.624247, longitude: 54.285306)]
            
            let dubaiCoordinates = [Coordinate(latitude: 25.36308, longitude: 55.288780)
                                    ,Coordinate(latitude: 25.234892, longitude: 55.562463)
                                    ,Coordinate(latitude: 24.953261, longitude: 54.812796)
                                    ,Coordinate(latitude: 24.794440, longitude: 55.077634)]
            
            regions = RegionsCreator.regionsFrom(coordinates: dubaiCoordinates)
            
            addRegionsPolygons()
            fitMapToCoordinates(dubaiCoordinates)
            addShowRegionButton()
        }
        
        
        setupRegionsTree()
        setupMQTT()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(self is RegionShowerViewController) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !(self is RegionShowerViewController) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    
    // MARK: - UI initlization
    func configureUI() {
        view.backgroundColor = .purple
        setupMap()
        
    }
    
    func addShowRegionButton() {
        let button = UIButton(frame: .zero)
        button.setImage(#imageLiteral(resourceName: "add"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "add"), for: .selected)
        button.backgroundColor = .init(red: 66/255, green: 139/255, blue: 199/255, alpha: 1)
        
        view.addSubview(button)
        button.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 25, right: 25), size: .init(width: 50, height: 50))
        button.layer.cornerRadius = 25
        
        button.addTarget(self, action: #selector(showRegionButtonPressed), for: .touchUpInside)
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 24.96334, longitude: 55.477316, zoom: 12)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        view.addSubview(mapView)
    }
    
    
    // MARK: - MQTT initlization
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
    
    
    // MARK: - constructing Tree
    @objc func setupRegionsTree() {
        
        tree = IntervalTree()
        regions.sort()
        
        tree.constructTreeWith(regions: regions)
        
        tree.print2dD()
        
    }
    
    
    // MARK: - actions
    @objc func showRegionButtonPressed() {
        navigationController?.pushViewController(AddCoordinatesViewController(), animated: true)
    }
    
}

// MARK: - Map operations
extension BaseViewController {
    func putMarkersOnMap(from coordinates: [[Coordinate]]) {
        for i in 0..<coordinates.count {
            for j in 0..<coordinates[i].count {
                let marker = GMSMarker(position: coordinates[i][j].coordinate2D)
                marker.title = "\(i) \(j)"
                marker.map = self.mapView
            }
        }
    }
    
    func addRegionsPolygons() {
        
        for (i, region) in regions.enumerated()
        {
            let path = GMSMutablePath()
            
            path.add( region.edgeCoordinates.edgeA.coordinate2D )
            path.add( region.edgeCoordinates.edgeB.coordinate2D )
            path.add( region.edgeCoordinates.edgeC.coordinate2D)
            path.add( region.edgeCoordinates.edgeD.coordinate2D )
    
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = colors[i % colors.count].withAlphaComponent(0.2)
            polygon.strokeColor = colors[i % colors.count]
            polygon.strokeWidth = 2
            polygon.map = mapView
        }

        //        putMarkersOnMap(from: [regions.map { $0.centerCoordinate }] )
        
    }
    
    func fitMapToCoordinates(_ coordinates: [Coordinate]) {
        let firstLocation = coordinates.first!
        
        var bounds = GMSCoordinateBounds(coordinate:firstLocation.coordinate2D, coordinate: firstLocation.coordinate2D)
        
        for coordinate in coordinates {
            bounds = bounds.includingCoordinate(coordinate.coordinate2D)
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(15))
        self.mapView.animate(with: update)
    }
}
