//
//  BTreeTests.swift
//  BTreeTests
//
//  Created by Bernardo Breder on 22/08/15.
//  Copyright (c) 2015 breder. All rights reserved.
//

import UIKit
import XCTest

class BTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let table: NSTable = NSTable(name: "person")
        XCTAssert(1 == table.add("a"), "")
        XCTAssert("a" == table.get(1), "")
        XCTAssert(2 == table.add("b"), "")
        XCTAssert("a" == table.get(1), "")
        XCTAssert("b" == table.get(2), "")
        XCTAssert(3 == table.add("c"), "")
        XCTAssert("a" == table.get(1), "")
        XCTAssert("b" == table.get(2), "")
        XCTAssert("c" == table.get(3), "")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
