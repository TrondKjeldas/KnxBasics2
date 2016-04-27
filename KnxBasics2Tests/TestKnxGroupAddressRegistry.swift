//
//  TestKnxGroupAddressRegistry.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 26/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//
import XCTest
@testable import KnxBasics2

class TestKnxGroupAddressRegistry: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"),
                                                       type: KnxTelegramType.DPT1_xxx)
        
        KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"8/9/10"),
                                                       type: KnxTelegramType.DPT5_001)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddressNotFound() {
        
        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"5/6/7")),
                       KnxTelegramType.UNKNOWN)
    }
    
    func testAddressFound() {

        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3")),
                       KnxTelegramType.DPT1_xxx)

        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"8/9/10")),
                       KnxTelegramType.DPT5_001)
    }
}
