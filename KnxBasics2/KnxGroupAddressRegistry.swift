//
//  GroupAddressRegistry.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 26/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxGroupAddressRegistry {
    
    private static var registry : [KnxGroupAddressImplementation : KnxTelegramType] = [:]
    
    public static func getTypeForGroupAddress(address : KnxGroupAddress) -> KnxTelegramType {
    
        let address = address as! KnxGroupAddressImplementation
        
        if let address = registry[address] {
            return address
        }
        else {
            print("Address not in registry: \(address)")
            return KnxTelegramType.UNKNOWN
        }
    }
    
    public static func addTypeForGroupAddress(address : KnxGroupAddress,
                                              type : KnxTelegramType) {
        
        let address = address as! KnxGroupAddressImplementation

        registry[address] = type
    }
}
