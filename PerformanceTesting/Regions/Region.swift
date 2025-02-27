//
//  Region.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/3/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

class Region {

    // MARK: - variables
    let id: Int
    let edgeCoordinates: EdgeCoordinates
    var neighbours: [Region]
    var indexAtArray: Int?
    
    
    // MARK: - init
    init(id: Int, edgeCoordinates: EdgeCoordinates, neighbours: [Region]) {
        self.id = id
        self.edgeCoordinates = edgeCoordinates
        self.neighbours = neighbours
    }
    
    
    // MARK: - methods
    func contains(_ coordinate: Coordinate) -> Bool {
        return pointInRegion(point: coordinate)
    }
    
    func neighbour(for coordinate: Coordinate) -> Region? {
        return neighbours.first(where: { (neighbourRegion) -> Bool in
            neighbourRegion.contains(coordinate)
        })
    }
    
}

// MARK: - Computed properties
extension Region {
    
    var centerCoordinate: Coordinate {
        return Coordinate(latitude: (edgeCoordinates.edgeB.latitude + edgeCoordinates.edgeD.latitude) / 2, longitude: (edgeCoordinates.edgeB.longitude + edgeCoordinates.edgeD.longitude) / 2)
    }
    
    // https://www.math-only-math.com/distance-of-a-point-from-the-origin.html
    var distanceFromOrigin: Double {
        return sqrt( (pow(centerCoordinate.latitude, 2) + pow(centerCoordinate.longitude, 2)) )
    }
}

extension Region
{
    // https://math.stackexchange.com/a/190373
    // https://stackoverflow.com/questions/2752725/finding-whether-a-point-lies-inside-a-rectangle-or-not/37865332#37865332
    fileprivate func vector(point1: Coordinate, point2: Coordinate) -> (x: Double, y: Double) {
        return ((point2.latitude - point1.latitude), (point2.longitude - point1.longitude))
    }
    
    fileprivate func dot(_ lhs: (x: Double, y: Double), _ rhs: (x: Double, y: Double)) -> Double {
        return lhs.x * rhs.x + lhs.y * rhs.y
    }
    
    fileprivate func pointInRegion(point: Coordinate) -> Bool
    {
        let AB = vector(point1: edgeCoordinates.edgeA, point2: edgeCoordinates.edgeB)
        let AM = vector(point1: edgeCoordinates.edgeA, point2: point)
        let BC = vector(point1: edgeCoordinates.edgeB, point2: edgeCoordinates.edgeC)
        let BM = vector(point1: edgeCoordinates.edgeB, point2: point)
        
        let dotABAM = dot(AB, AM);
        let dotABAB = dot(AB, AB);
        let dotBCBM = dot(BC, BM);
        let dotBCBC = dot(BC, BC);
        
        return (0 <= dotABAM && dotABAM <= dotABAB) && (0 <= dotBCBM && dotBCBM <= dotBCBC)
    }
}

extension Region: CustomStringConvertible {
    var description: String {
        return "regions with id: \(id)"
    }
}

extension Region: Comparable {
    static func < (lhs: Region, rhs: Region) -> Bool {
        return sqrt( (pow(lhs.centerCoordinate.latitude, 2) + pow(lhs.centerCoordinate.longitude, 2)) ) < sqrt( (pow(rhs.centerCoordinate.latitude, 2) + pow(rhs.centerCoordinate.longitude, 2)) )
    }
    
    static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.edgeCoordinates == rhs.edgeCoordinates
    }
}

extension Region: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case edgeCoordinates
        case neighbours
        case centerPoint
        case distanceFromOrigin
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(edgeCoordinates, forKey: .edgeCoordinates)
        try container.encode(centerCoordinate, forKey: .centerPoint)
        try container.encode(distanceFromOrigin, forKey: .distanceFromOrigin)
        
        let indexs = neighbours.compactMap { $0.indexAtArray }
        try container.encode(indexs, forKey: .neighbours)
    }
}
