//
//  Tree.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/2/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

class IntervalTree {
    
    var head: TreeNode?
    
    func printOrderTree() {
        guard let head = head else {
            print("Empty Tree...")
            return
        }
        print("")
        print("-------------------------------------------------------------")
        print("")
        printOrderTree(node: head)
    }
    
    fileprivate func printOrderTree(node: TreeNode?) {
        if let left = node?.left {
            printOrderTree(node: left)
        }
        
        print(node!)
        
        if let right = node?.right {
            printOrderTree(node: right)
        }
        
    }
    
    func constructTreeWith(regions: [Region]) {
        head = TreeNode()
        constructTreeWith(regions: regions, parentNode: head!)
    }
    
    fileprivate func constructTreeWith(regions: [Region], parentNode: TreeNode) {
        
        let mid = (regions.count - 1) / 2
        
        if mid >= 0 && regions.count > 0
        {
            parentNode.region = regions[mid]
            
            let leftRange = getLeftRanges(regions: regions, mid: mid)
            if leftRange.count > 0 {
                parentNode.left = TreeNode()
                constructTreeWith(regions: leftRange, parentNode: parentNode.left!)
            }
            
            let rightRange = getRightRanges(regions: regions, mid: mid)
            if rightRange.count > 0 {
                parentNode.right = TreeNode()
                constructTreeWith(regions: rightRange, parentNode: parentNode.right!)
            }
        }
    }
    
    
    func nodeFor(value: Coordinate) -> TreeNode? {
        guard let head = head else {
            return nil
        }
        
        let coordinateDistanceFromOrigin = sqrt( (pow(value.latitude, 2) + pow(value.longitude, 2)) )
        
        return nodeFor(value: value, parent: head, coordinateDistanceFromOrigin: coordinateDistanceFromOrigin)
    }
    
    fileprivate func nodeFor(value: Coordinate, parent: TreeNode, coordinateDistanceFromOrigin: Double) -> TreeNode? {

        
        print(parent)
        if parent.region.contains(value)
        {
            return parent
        }
        
        if coordinateDistanceFromOrigin < parent.region.distanceFromOrigin
        {
            if let left = parent.left
            {
                let newNode = nodeFor(value: value, parent: left, coordinateDistanceFromOrigin: coordinateDistanceFromOrigin)
                if newNode != nil {
                    return newNode
                }
            }
        }
        else
        {
            if let right = parent.right
            {
                let newNode = nodeFor(value: value, parent: right, coordinateDistanceFromOrigin: coordinateDistanceFromOrigin)
                if newNode != nil {
                    return newNode
                }
            }
        }
        
        return nil
        
    }
}


// MARK: - helepers
extension IntervalTree {
    fileprivate func getLeftRanges(regions: [Region], mid: Int) -> [Region] {
        return regions.enumerated().compactMap({ (i,_) -> Region? in
            if i >= 0, i < mid {
                return regions[i]
            }
            return nil
        })
    }
    
    fileprivate func getRightRanges(regions: [Region], mid: Int) -> [Region] {
        return regions.enumerated().compactMap({ (i,_) -> Region? in
            if i > mid, i < regions.count {
                return regions[i]
            }
            return nil
        })
    }
    
}


extension IntervalTree {
    
    func printLevelOrder() {
        let treeHeight = height(for: head)
        for i in 1...treeHeight {
            printGivenLevel(root: head, level: i)
        }
    }
    
    fileprivate func printGivenLevel(root: TreeNode?, level: Int) {
        guard let root = root else { return }
        
        if level == 1
        {
            print(root.region.id, separator: " ", terminator: " ")
        }
        else if level > 1
        {
            printGivenLevel(root: root.left, level: level - 1)
            printGivenLevel(root: root.right, level: level - 1)
        }
    }
    
    fileprivate func height(for root: TreeNode?) -> Int {
        if root == nil {
            return 0
        }
        
        let leftHeight: Int = height(for: root?.left)
        let rightHeight: Int = height(for: root?.left)
        
        if leftHeight > rightHeight {
            return leftHeight + 1
        } else {
            return rightHeight + 1
        }
    }
}

let COUNT = 10;

extension IntervalTree
{
    func print2dD() {
        guard let head = head else { return }
        print2D(root: head, space: 0)
    }
    
    fileprivate func print2D(root: TreeNode?, space: Int)
    {
        guard let root = root else { return }
        
        let newSpace = space + COUNT
        print2D(root: root.right, space: newSpace)
        
        print("")
        
        for _ in COUNT..<newSpace {
            print(" ", separator: "", terminator: "")
        }
        
        print(root)
        
        print2D(root: root.left, space: newSpace)
    }
}




