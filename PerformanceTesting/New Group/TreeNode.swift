//
//  Node.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/3/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

class TreeNode {
    
    var left: TreeNode?
    var right: TreeNode?
    
    var region: Region!
    
    init(region: Region) {
        self.region = region
    }
    
    init() {
        
    }
}

extension TreeNode: CustomStringConvertible {
    var description: String {
        return "Region: \(region.id)"
    }
}
