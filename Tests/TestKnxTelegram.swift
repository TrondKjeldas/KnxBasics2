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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDPT1_xxx() {
        
        var bytes = [UInt8](repeating: 0, count: 8)
        
        bytes[7] = 0xFE
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt1_xxx), 0)

        bytes[7] = 0xaF
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt1_xxx), 1)
    }
    
    func testDPT3_007() {
        
        var bytes = [UInt8](repeating: 0, count: 8)
        
        bytes[7] = 0x00
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt3_007), 0)
        
        bytes[7] = 0x01
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt3_007), -1)

        bytes[7] = 0x09
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt3_007), 1)
    }
    
    func testDPT5_001() {
        
        var bytes = [UInt8](repeating: 0, count: 9)
        
        
        bytes[8] = 0x00
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt5_001), 0 )

        bytes[8] = 128
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt5_001), 50 )

        bytes[8] = 0xFF
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt5_001), 100 )

    }

    
    func testDPT9_001() {
    
        var bytes = [UInt8](repeating: 0, count: 10)

        // Zero
        bytes[8] = 0x00
        bytes[9] = 0x00
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), 0.0, accuracy: 0.01)

        // Positive temperatures
        bytes[8] = 0x07
        bytes[9] = 0xE2
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), 20.18, accuracy: 0.01)

        bytes[8] = 0x02
        bytes[9] = 0xA8
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), 6.8, accuracy: 0.01)

        // Negative temperatures
        bytes[8] = 0x87
        bytes[9] = 0x9C
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), -1.0, accuracy: 0.01)
        
        bytes[8] = 0x8A
        bytes[9] = 0x24
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), -30.0, accuracy: 0.01)
        
        // Lower limit
        bytes[8] = 0xF8
        bytes[9] = 0x00
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), -671088.64, accuracy: 0.01)
        
        // Upper limit
        bytes[8] = 0x7F
        bytes[9] = 0xFF
        XCTAssertEqualWithAccuracy(try KnxTelegram(bytes: bytes).getValueAsType(.dpt9_001), 670760.96, accuracy: 0.01)
    }
    
    func testDPT9_004() {

        // Same format for now...
        testDPT9_001()
        
    }
    
    func testDPT9_005() {
        
        // Same format for now...
        testDPT9_001()
    }

    func testDPT10_001() {
        
        var bytes = [UInt8](repeating: 0, count: 11)

        bytes[8] = 0x00
        bytes[9] = 0x00
        bytes[10] = 0x00
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt10_001), "?? 00:00:00")

        bytes[8] = 0x2C
        bytes[9] = 0x1E
        bytes[10] = 0x1E
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt10_001), "Mon 12:30:30")
        
        bytes[8] = 0xF7
        bytes[9] = 0x3B
        bytes[10] = 0x3B
        XCTAssertEqual(try KnxTelegram(bytes: bytes).getValueAsType(.dpt10_001), "Sun 23:59:59")
    }
    
    
    func testDPT17_001() {
        
        XCTAssertTrue(false)
        
    }
    
    func testDPT20_102() {
        
        XCTAssertTrue(false)
        
    }
    
    func testDPT27_001() {
        
        XCTAssertTrue(false)
        
    }
}
