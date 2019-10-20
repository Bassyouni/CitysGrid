//
//  BaseViewController+Extension.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/20/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

extension BaseViewController {
    func setupGrid() {
        
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
        
        
        addRegionsPolygons(with: gridArray)
        addNeighnours(rowCount: (gridArray.first?.count ?? 0) - 1 )
        
        
    }
    
    func getGridFormArrays(length arrayLength: [Coordinate], width arrayWidth: [Coordinate]) -> [[Coordinate]] {
        
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
    
    func getSlopeAndBValueFrom(point1: Coordinate, point2: Coordinate) -> (slope: Double, bValue: Double) {
        
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
        
        tree.constructTreeWith(regions: regions)
        
        let tacmeLocation = Coordinate(latitude: 25.285876, longitude: 55.477316)
        let sharjaOutSideDubaiLocation = Coordinate(latitude: 25.298839, longitude: 55.481870)
        
        
        //        if let node = tree.nodeFor(value: tacmeLocation) {
        //            putMarkersOnMap(from: [[tacmeLocation]])
        //            print(node)
        //        }
        //
        //        if let node = tree.nodeFor(value: sharjaOutSideDubaiLocation) {
        //            putMarkersOnMap(from: [[sharjaOutSideDubaiLocation]])
        //            print(node)
        //        }
        
        tree.print2dD()
        
    }
    
    func addNeighnours(rowCount: Int) {
        
        guard rowCount > 0 && regions.count % rowCount == 0 else { return }
        
        var regionsMatrix = [[Region]]()
        
        let topLevelCount = regions.count / rowCount
        
        for i in 0..<topLevelCount
        {
            var tempArray = [Region]()
            
            for j in 0..<rowCount
            {
                tempArray.append(regions[(i * rowCount) + j])
            }
            regionsMatrix.append(tempArray)
        }
        
        for x in 0..<regionsMatrix.count
        {
            for (y, region) in regionsMatrix[x].enumerated()
            {
                if x+1 < regionsMatrix.count
                {
                    region.neighbours.append(regionsMatrix[x+1][y])
                    if y + 1 < regionsMatrix[x+1].count
                    {
                        region.neighbours.append(regionsMatrix[x+1][y+1])
                    }
                    if y - 1 >= 0
                    {
                        region.neighbours.append(regionsMatrix[x+1][y-1])
                    }
                }
                
                if x-1 >= 0
                {
                    region.neighbours.append(regionsMatrix[x-1][y])
                    if y + 1 < regionsMatrix[x-1].count
                    {
                        region.neighbours.append(regionsMatrix[x-1][y+1])
                    }
                    if y - 1 >= 0
                    {
                        region.neighbours.append(regionsMatrix[x-1][y-1])
                    }
                }
                
                if y + 1 < regionsMatrix[x].count
                {
                    region.neighbours.append(regionsMatrix[x][y+1])
                }
                if y - 1 >= 0
                {
                    region.neighbours.append(regionsMatrix[x][y-1])
                }
            }
        }
        
        
    }
}
