//
//  RegionsCreator.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/27/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation


class RegionsCreator
{
    // MARK: - public functions
    static func regionsFrom(coordinates: [Coordinate]) -> [Region] {
        return setupGridWithEdgeCoordinates(coordinates)
    }
    
    
    // MARK: - private functions
    class private func setupGridWithEdgeCoordinates(_ coordinates: [Coordinate]) -> [Region] {
        guard coordinates.count == 4 else {
            print("edges must be only 4 coordinates")
            return []
        }
        
        let sortedLlatitudeArray = coordinates.sorted(by: { a,b in a.latitude < b.latitude })
        
        let topLatitude = [sortedLlatitudeArray[2], sortedLlatitudeArray[3]].sorted(by: { a,b in a.longitude < b.longitude })
        let bottomLatitude = [sortedLlatitudeArray[0], sortedLlatitudeArray[1]].sorted(by: { a,b in a.longitude < b.longitude })
        
        
        let topLeft = topLatitude[0]
        let topRight = topLatitude[1]
        
        let bottomLeft = bottomLatitude[0]
        let bottomRight = bottomLatitude[1]
        
        return setupGrid(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }
    
    class private func setupGrid(topLeft: Coordinate, topRight: Coordinate, bottomLeft: Coordinate, bottomRight: Coordinate) -> [Region] {
    
        var bottomLengthCoordinate: Coordinate!
        var topLengthCoordinate: Coordinate!
        var startingWidthCoordinate: Coordinate!
        var endingWidthCoordinate: Coordinate!
        
        if bottomLeft.location.distance(from: topLeft.location) >= bottomRight.location.distance(from: topRight.location)
        {
            topLengthCoordinate = topLeft
            bottomLengthCoordinate = bottomLeft
        }
        else
        {
            topLengthCoordinate = topRight
            bottomLengthCoordinate = bottomRight
        }
        
        if bottomLeft.location.distance(from: bottomRight.location) >= topLeft.location.distance(from: topRight.location)
        {
            if bottomLengthCoordinate == bottomLeft
            {
                startingWidthCoordinate = bottomLeft
                endingWidthCoordinate = bottomRight
            }
            else
            {
                startingWidthCoordinate = bottomRight
                endingWidthCoordinate = bottomLeft
            }
            
        }
        else
        {
            if topLengthCoordinate == topRight
            {
                startingWidthCoordinate = topRight
                endingWidthCoordinate = topLeft
            }
            else
            {
                startingWidthCoordinate = topLeft
                endingWidthCoordinate = topRight
            }
            
        }
        
        var arrayLength: [Coordinate] = [bottomLengthCoordinate]
        var arrayWidth: [Coordinate] = []
        
        let xLengthDif = abs(topLengthCoordinate.latitude - bottomLengthCoordinate.latitude)
        let yLengthDif = abs(topLengthCoordinate.longitude - bottomLengthCoordinate.longitude)
        
        let xWitdhDif = abs(startingWidthCoordinate.latitude - endingWidthCoordinate.latitude)
        let yWitdhDif = abs(startingWidthCoordinate.longitude - endingWidthCoordinate.longitude)
        
        
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
            
            if bottomLengthCoordinate.latitude < topLengthCoordinate.latitude {
                newLengthLat = bottomLengthCoordinate.latitude + ( xLengthDif * step )
            } else {
                newLengthLat = bottomLengthCoordinate.latitude - ( xLengthDif * step )
            }
            
            if bottomLengthCoordinate.longitude < topLengthCoordinate.longitude {
                newLengthLong = bottomLengthCoordinate.longitude + (yLengthDif * step )
            } else {
                newLengthLong = bottomLengthCoordinate.longitude - (yLengthDif * step )
            }
            
            arrayLength.append(Coordinate(latitude: newLengthLat, longitude: newLengthLong))
            
            var newWidthLat: Double!
            var newWidthLong: Double!
            
            if startingWidthCoordinate.latitude < endingWidthCoordinate.latitude {
                newWidthLat = startingWidthCoordinate.latitude + ( xWitdhDif * step )
            } else {
                newWidthLat = startingWidthCoordinate.latitude - ( xWitdhDif * step )
            }
            
            if startingWidthCoordinate.longitude < endingWidthCoordinate.longitude {
                newWidthLong = startingWidthCoordinate.longitude + (yWitdhDif * step )
            } else {
                newWidthLong = startingWidthCoordinate.longitude - (yWitdhDif * step )
            }
            
            arrayWidth.append(Coordinate(latitude: newWidthLat, longitude: newWidthLong))
        }
        
        arrayLength.append(topLengthCoordinate)
        arrayWidth.append(endingWidthCoordinate)
        
        let gridArray = getGridFormArrays(length: arrayLength, width: arrayWidth)
        
        
        let regions = createRegions(with: gridArray)
        addNeighbors(to: regions, rowCount: (gridArray.first?.count ?? 0) - 1)

        return regions
    }
    
    class private func getGridFormArrays(length arrayLength: [Coordinate], width arrayWidth: [Coordinate]) -> [[Coordinate]] {
        
        // Reference's
        // Point of intersection between two lines
        // https://www.mathopenref.com/coordintersection.html
        // how to get the slope of line parallel to another line
        // http://www.mesacc.edu/~scotz47781/mat150/notes/eqn_line/Equation_Line_Parallel_Perpendicular_Notes.pdf
        // how to get the b value with slope and one point
        // https://www.mathplanet.com/education/algebra-1/formulating-linear-equations/writing-linear-equations-using-the-slope-intercept-form
        
        
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
    
    class private func getSlopeAndBValueFrom(point1: Coordinate, point2: Coordinate) -> (slope: Double, bValue: Double) {
        
        let lineSlope = (point2.longitude - point1.longitude) / (point2.latitude - point1.latitude)
        
        // y = mx + b <--
        // y - mx = b
        // y = (lineSlope * X) + lineBValue
        let lineBValue = point1.longitude - (lineSlope * point1.latitude)
        
        return (lineSlope, lineBValue)
    }
    
    class private func createRegions(with grid: [[Coordinate]]) -> [Region] {
        
        var regions = [Region]()
        
        for i in 0..<grid.count - 1
        {
            for j in 0..<(grid[i].count - 1)
            {
                let firstPoint = grid[i][j]
                let secondPoint = grid[i + 1][j]
                let thirdPoint = grid[i + 1][j + 1]
                let fourthPoint = grid[i][j + 1]
                
                let edgeCoordinates = EdgeCoordinates([firstPoint, secondPoint, thirdPoint, fourthPoint])
                regions.append(Region(id: Int("\(j+1)\(i+1)")!, edgeCoordinates: edgeCoordinates, neighbours: []))
            }
        }
        return regions
    }
    
    class private func addNeighbors(to regions: [Region], rowCount: Int) {
        
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

