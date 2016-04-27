//
//  KnxTelegramFactoryImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxTelegramFactory {
    
    public static func createSubscriptionRequest(groupAddress:KnxGroupAddress) -> KnxTelegram {
        
        let addrLow8 = UInt8(truncatingBitPattern:(groupAddress.addressAsUInt16 & 0xFF))
        let addrHigh8 = UInt8(truncatingBitPattern:(groupAddress.addressAsUInt16 >> 8))
        
        var bytes:[UInt8] = [UInt8](count:7, repeatedValue:0)
        // Length...
        bytes[0] = 0;
        bytes[1] = 5;
        // Content
        bytes[2] = 0;
        bytes[3] = 34;
        bytes[4] = addrHigh8
        bytes[5] = addrLow8
        bytes[6] = 0x00;
    
        
        
        return KnxTelegram(bytes: bytes)
    }
    
    public static func createWriteRequest(type:KnxTelegramType, value:Int) -> KnxTelegram {
        
        var bytes:[UInt8] = [UInt8](count:6, repeatedValue:0)
        // Length...
        bytes[0] = 0;
        bytes[1] = 4;
        // Content
        bytes[2] = 0;
        bytes[3] = 37;
        bytes[4] = 0
        bytes[5] = UInt8(truncatingBitPattern:value) | 0x80
        
        
        return KnxTelegram(bytes: bytes)
    }

}
