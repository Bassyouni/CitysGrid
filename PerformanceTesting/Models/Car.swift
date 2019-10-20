//
//  Car.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/20/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

struct Car: Decodable, Equatable {
    
    var carId: Int
    var lat: Double?
    var long: Double?
    var action: String?
    
    var coordinate: Coordinate? {
        guard let lat = lat, let long = long else { return nil }
        return Coordinate(latitude: lat, longitude: long)
    }
    
    static func == (lhs: Car, rhs: Car) -> Bool {
        return lhs.carId == rhs.carId
    }
}
