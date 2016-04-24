//
//  KnxTelegramFactoryImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxTelegramFactoryImplementation : KnxTelegramFactory {
    
    required public init() {
        
    }
    
    public func createSubscriptionRequest(groupAddress:KnxGroupAddress) -> KnxTelegram {
        
        let address = groupAddress.addressAsUInt16
        
        
        //let address:UInt16 = 1 << 11 | 0 << 8 | addr
        
        let addrLow:UInt16 = (address & 0xFF)
        let addrHigh:UInt16 = (address >> 8)
        let addrLow8 = UInt8(truncatingBitPattern:addrLow)
        let addrHigh8 = UInt8(truncatingBitPattern:addrHigh)
        
        var bytes:[UInt8] = [UInt8](count:7, repeatedValue:0)
        bytes[4] = addrHigh8
        bytes[5] = addrLow8
        bytes[6] = 0x00;
        bytes[2] = 0;
        bytes[3] = 34;
        
        // Add length...
        bytes[0] = 0;
        bytes[1] = 5;
        
        return KnxTelegramImplementation(bytes: bytes)
    }
}
