//
//  File.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/14/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

struct EdgeCoordinates {

    var edgeA: Coordinate
    var edgeB: Coordinate
    var edgeC: Coordinate
    var edgeD: Coordinate
    
    init(_ coordinates: [Coordinate]) {
        guard coordinates.count == 4 else {
            fatalError("EdgeCoordinates must have 4 points")
        }
        
        edgeA = coordinates[0]
        edgeB = coordinates[1]
        edgeC = coordinates[2]
        edgeD = coordinates[3]
    }

}

extension EdgeCoordinates: Equatable {
    static func == (lhs: EdgeCoordinates, rhs: EdgeCoordinates) -> Bool {
        return (lhs.edgeA == rhs.edgeA) && (lhs.edgeB == rhs.edgeB) && (lhs.edgeC == rhs.edgeC) && (lhs.edgeD == rhs.edgeD)
    }
}

extension EdgeCoordinates: Encodable {
    enum CodingKeys: String, CodingKey {
        case edgeA
        case edgeB
        case edgeC
        case edgeD
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(edgeA, forKey: .edgeA)
        try container.encode(edgeB, forKey: .edgeB)
        try container.encode(edgeC, forKey: .edgeC)
        try container.encode(edgeD, forKey: .edgeD)
    }
}
