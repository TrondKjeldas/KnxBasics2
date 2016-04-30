//
//  KnxTelegramFactory.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

/// Factory class to create KNX telegrams of various type.
public class KnxTelegramFactory {

    // MARK: Public API

    /**
     Create a subscription request.

     - parameter groupAddress: The group address to subscribe to.

     - returns: A subscription request telegram, ready to be sent.
     */
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

    /**
     Create a write request telegram.

     - parameter type: DPT type.
     - parameter value: The value to write, as an integer.

     - returns: A telegram, ready to be sent.
     */
    public static func createWriteRequest(type:KnxTelegramType, value:Int) throws -> KnxTelegram {

      var bytes:[UInt8]

        switch type {

        case .DPT1_xxx:
            
            bytes = [UInt8](count:6, repeatedValue:0)
            // Length...
            bytes[0] = 0
            bytes[1] = 4
            // Content
            bytes[2] = 0;
            bytes[3] = 37
            bytes[4] = 0
            bytes[5] = UInt8(truncatingBitPattern:value) | 0x80
            
            break;
            
        case .DPT5_001:
            
            bytes = [UInt8](count:7, repeatedValue:0)
            
            // Length...
            bytes[0] = 0
            bytes[1] = 5
            // Content
            bytes[2] = 0
            bytes[3] = 37
            bytes[4] = 0
            bytes[5] = 0x80
            bytes[6] = UInt8(truncatingBitPattern:((value * 255) / 100)) /* Convert range from 0-100 to 8bit */
            
        default:
            throw KnxException.UnknownTelegramType
        }
        
      return KnxTelegram(bytes: bytes)
    }
}
