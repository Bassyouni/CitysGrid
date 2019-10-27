//
//  Coordinate.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/3/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinate: Equatable {
    
    var latitude: Double
    var longitude: Double
    var location: CLLocation
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var coordinate2D: CLLocationCoordinate2D {
        return location.coordinate
    }
}

extension Coordinate: Encodable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
    


