//
//  TestTelegramFactory.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 28/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//
import XCTest
@testable import KnxBasics2

class TestKnxTelegramFactory: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateSubscriptionRequest() {
       
        XCTAssertNotNil(KnxTelegramFactory.createSubscriptionRequest(KnxGroupAddress(fromString:"8/9/10")))
    }
    
    func testAddressFound() {
        
        XCTAssertNotNil(KnxTelegramFactory.createWriteRequest(KnxTelegramType.DPT5_001, value: 1))
    }
}
