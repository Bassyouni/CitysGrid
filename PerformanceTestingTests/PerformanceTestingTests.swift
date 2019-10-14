//
//  PerformanceTestingTests.swift
//  PerformanceTestingTests
//
//  Created by Bassyouni on 10/2/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import XCTest
@testable import PerformanceTesting

class PerformanceTestingTests: XCTestCase {
    
    let tree = IntervalTree()

    override func setUp() {
        
//        var regions = [Region]()
//
//        for i in 1...500 {
//
//            rawRanges.append(Double( (Double(i) * 500 + Double.random(in: 0.00000000001...0.99999999999)))...Double((Double(i) * 500 + 500 + Double.random(in: 0.00000000001...0.99999999999))) )
//        }
////        [(0...500), (501...1000), (1001...1500), (1501...2000), (2001...2500), (2501...3000), (3001...3500)]
//
//        tree.constructTreeWith(ranges: rawRanges)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
       
        self.measure {
//            var value = Double.random(in: 1...500)
//            value = value * 500
//            value = value + Double.random(in: 0.00000000001...0.99999999999)
//            print("ok: \(value)")
//            print(tree.nodeFor(value: value) as Any)
        }
    }

}
