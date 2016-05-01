//
//  TestKnxTelegram.swift
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

class TestKnxTelegram: XCTestCase {
    
    var bytes = [UInt8](count:10, repeatedValue:0)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDPT9_001() {
        
        bytes[8] = 0x07
        bytes[9] = 0xE2
        //XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.DPT9_001), 20.18, accuracy: 0.01)

        bytes[8] = 0x02
        bytes[9] = 0xA8
        //XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.DPT9_001), 6.8, accuracy: 0.01)

        bytes[8] = 0x87
        bytes[9] = 0x74
        //XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.DPT9_001), -1.40, accuracy: 0.01)

        // Lower limit
        bytes[8] = 0xFF
        bytes[9] = 0xFF
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.DPT9_001), -671088.64, accuracy: 0.01)
        
        // Upper limit
        bytes[8] = 0x7F
        bytes[9] = 0xFF
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.DPT9_001), 670760.96, accuracy: 0.01)
    }
}