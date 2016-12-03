//
//  TestKnxGroupAddressRegistry.swift
//  KnxBasics2
//
//  The KnxBasics2 framework provides basic interworking with a KNX installation.
//  Copyright © 2016 Trond Kjeldås (trond@kjeldas.no).
//
//  This library is free software; you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License Version 2.1
//  as published by the Free Software Foundation.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this library; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
import XCTest
@testable import KnxBasics2

class TestKnxGroupAddressRegistry: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"),
                                                       type: KnxTelegramType.dpt1_xxx)
        
        KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"8/9/10"),
                                                       type: KnxTelegramType.dpt5_001)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddressNotFound() {
        
        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"5/6/7")),
                       KnxTelegramType.unknown)
    }
    
    func testAddressFound() {

        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3")),
                       KnxTelegramType.dpt1_xxx)

        XCTAssertEqual(KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"8/9/10")),
                       KnxTelegramType.dpt5_001)
    }
}
