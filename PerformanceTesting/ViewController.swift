//
//  ViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/2/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var tree: IntervalTree!
    var mapView: GMSMapView!
    var regions = [Region]()
    
    let colors: [UIColor] = [UIColor.red, .blue, .magenta, .black, .purple, .cyan, .brown, .darkGray, .orange]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        
        
        setupMap()
        setupGrid()
        
        let button = UIButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 50, height: 50))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("again", for: .normal)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(setupRegions), for: .touchUpInside)
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        button.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.setupRegions()
        }
       
    }
    
    // MARK: - map
    fileprivate func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 25.089694, longitude: 55.256633, zoom: 9)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        view.addSubview(mapView)
    }
    
    fileprivate func putMarkersOnMap(from coordinates: [[Coordinate]]) {
        for i in 0..<coordinates.count {
            for j in 0..<coordinates[i].count {
                let marker = GMSMarker(position: coordinates[i][j].coordinate2D)
                marker.title = "\(i) \(j)"
                marker.map = self.mapView
            }
        }
    }
    
    fileprivate func addRegionsPolygons(with grid: [[Coordinate]]) {
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
        
        
        
        for (i , path) in polygonsPathArray.enumerated()
        {
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = colors[i % colors.count].withAlphaComponent(0.2)
            polygon.strokeColor = colors[i % colors.count]
            polygon.strokeWidth = 2
            polygon.map = mapView
        }
        
        
        putMarkersOnMap(from: [regions.map { $0.centerCoordinate }] )
        
    }
    
    // MARK: - grid algoritiom
    fileprivate func setupGrid() {
    
        let topLeft = Coordinate(latitude: 25.36308, longitude: 55.288780)
        let topRight = Coordinate(latitude: 25.234892, longitude: 55.562463)
        let bottomLeft = Coordinate(latitude: 24.953261, longitude: 54.812796)
        let bottomRight = Coordinate(latitude: 24.794440, longitude: 55.077634)
        
        var arrayLength: [Coordinate] = [bottomRight]
        var arrayWidth: [Coordinate] = []
        
        let xLengthDif = abs(topRight.latitude - bottomRight.latitude)
        let yLengthDif = abs(topRight.longitude - bottomRight.longitude)

        let xWitdhDif = abs(bottomLeft.latitude - bottomRight.latitude)
        let yWitdhDif = abs(bottomLeft.longitude - bottomRight.longitude)

        
        print("topLeft to topRight 'width': ",topLeft.location.distance(from: topRight.location) / 1000.0, " KM \n")
        print("bottomLeft to bottomRight 'width': ",bottomLeft.location.distance(from: bottomRight.location) / 1000.0, " KM \n")
        print("bottomLeft to topLeft 'length': ",bottomLeft.location.distance(from: topLeft.location) / 1000.0, " KM \n")
        print("bottomRight to topRight 'length': ",bottomRight.location.distance(from: topRight.location) / 1000.0, " KM \n")
        
        
        let n: Double = 4
        for i in 1..<Int(n)
        {
            let step = (Double(i) / n)
            
            var newLengthLat: Double!
            var newLengthLong: Double!
            
            if bottomRight.latitude < topRight.latitude {
                newLengthLat = bottomRight.latitude + ( xLengthDif * step )
            } else {
                newLengthLat = bottomRight.latitude - ( xLengthDif * step )
            }
            
            if bottomRight.longitude < topRight.longitude {
                newLengthLong = bottomRight.longitude + (yLengthDif * step )
            } else {
                newLengthLong = bottomRight.longitude - (yLengthDif * step )
            }
            
            arrayLength.append(Coordinate(latitude: newLengthLat, longitude: newLengthLong))

            var newWidthLat: Double!
            var newWidthLong: Double!
            
            if bottomRight.latitude < bottomLeft.latitude {
                newWidthLat = bottomRight.latitude + ( xWitdhDif * step )
            } else {
                newWidthLat = bottomRight.latitude - ( xWitdhDif * step )
            }
            
            if bottomRight.longitude < bottomLeft.longitude {
                newWidthLong = bottomRight.longitude + (yWitdhDif * step )
            } else {
                newWidthLong = bottomRight.longitude - (yWitdhDif * step )
            }
            
            arrayWidth.append(Coordinate(latitude: newWidthLat, longitude: newWidthLong))
        }

        arrayLength.append(topRight)
        arrayWidth.append(bottomLeft)
        
        let gridArray = getGridFormArrays(length: arrayLength, width: arrayWidth)

        
//        putMarkersOnMap(from: gridArray)
        addRegionsPolygons(with: gridArray)
        

    }
    
    fileprivate func getGridFormArrays(length arrayLength: [Coordinate], width arrayWidth: [Coordinate]) -> [[Coordinate]] {
        
        let lengthEquation = getSlopeAndBValueFrom(point1: arrayLength[0], point2: arrayLength[arrayLength.count - 1])
        let widthEquation = getSlopeAndBValueFrom(point1: arrayWidth[0], point2: arrayWidth[arrayWidth.count - 1])
        
        var gridArray = [[Coordinate]]()
        
        for lengthCoordinate in arrayLength
        {
            let lineLenBValue = lengthCoordinate.longitude - (widthEquation.slope * lengthCoordinate.latitude)
            var array = [Coordinate]()
            for widthCoordinate in arrayWidth
            {
                let lineWidBValue = widthCoordinate.longitude - (lengthEquation.slope * widthCoordinate.latitude)
                
                // x first unkowen  = (bValue2 - bValue1) / (slope1 - slope2)
                let latX = (lineWidBValue - lineLenBValue) / (widthEquation.slope - lengthEquation.slope)
                // y second unkwon = (slope* x) + b
                let longY = (lengthEquation.slope * latX) + lineWidBValue
                array.append(Coordinate(latitude: latX, longitude: longY))
            }
            gridArray.append(array)
        }
        
        for i in 0..<arrayLength.count
        {
            gridArray[i].insert(arrayLength[i], at: 0)
        }
        
        return gridArray
    }
    
    fileprivate func getSlopeAndBValueFrom(point1: Coordinate, point2: Coordinate) -> (slope: Double, bValue: Double) {
        
        let lineSlope = (point2.longitude - point1.longitude) / (point2.latitude - point1.latitude)
        
        // y = mx + b <--
        // y - mx = b
        // y = (lineSlope * X) + lineBValue
        let lineBValue = point1.longitude - (lineSlope * point1.latitude)
        
        return (lineSlope, lineBValue)
    }
    
    
    
    // MARK: - saving and retrieving regions
    @objc func setupRegions() {
        
        tree = IntervalTree()
        regions.sort()
        
//        print(regions)
        
        tree.constructTreeWith(regions: regions)

        let tacmeLocation = Coordinate(latitude: 25.285876, longitude: 55.477316)
        let sharjaOutSideDubaiLocation = Coordinate(latitude: 25.298839, longitude: 55.481870)

        
//        tree.printLevelOrder()
//
//        tree.print2dD()
        
        if let node = tree.nodeFor(value: tacmeLocation) {
            putMarkersOnMap(from: [[tacmeLocation]])
            print(node)
        }

        if let node = tree.nodeFor(value: sharjaOutSideDubaiLocation) {
            putMarkersOnMap(from: [[sharjaOutSideDubaiLocation]])
            print(node)
        }
        
        tree.print2dD()
        
        func getDocumentsDirectory() -> URL {
            var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0].appendingPathComponent("mineJson")
            return documentsDirectory
        }
        
       
        

    }
    
}
