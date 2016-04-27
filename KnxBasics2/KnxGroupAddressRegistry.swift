///
/// - File:      GroupAddressRegistry.swift
/// - Framework: KnxBasics2
///
/// - author: Created by Trond Kjeldås on 26/04/16.
///  - Copyright: Copyright © 2016 Trond Kjeldås. All rights reserved.
///

import Foundation

/// A global registry for mapping group addresses to DPT types.
public class KnxGroupAddressRegistry {
    
    private static var registry : [KnxGroupAddress : KnxTelegramType] = [:]
    
    /// Look up a DPT type based on the group address
    ///
    /// - Parameters:
    ///     - address: The group address to look up
    ///
    /// - Returns: The DPT type registered for the address, or .UNKNOWN if the address is not registered
    public static func getTypeForGroupAddress(address : KnxGroupAddress) -> KnxTelegramType {
    
        if let address = registry[address] {
            return address
        }
        else {
            print("Address not in registry: \(address)")
            return KnxTelegramType.UNKNOWN
        }
    }
    
    /// Register a DPT type for a group address
    ///
    /// - Parameters:
    ///     - address: The group address to register a type for
    ///     - type:    The type to register
    public static func addTypeForGroupAddress(address : KnxGroupAddress,
                                              type : KnxTelegramType) {
        
        registry[address] = type
    }
}
