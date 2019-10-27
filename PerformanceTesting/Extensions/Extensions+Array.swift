//
//  Extensions+Array.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/27/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

extension Array where Element: Region {
    mutating func sortRegions() {
        sort()
        
        for i in 0..<count {
            self[i].indexAtArray = i
        }
    }
}
