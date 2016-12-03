//
//  GroupAddressRegistry.swift
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

import Foundation
import SwiftyBeaver

/// A global registry for mapping group addresses to DPT types.
open class KnxGroupAddressRegistry {
    
    // MARK: Public API.
    
    fileprivate static var registry : [KnxGroupAddress : KnxTelegramType] = [:]
    
    /**
     Look up a DPT type based on the group address.
     
     - parameter address: The group address to look up.
     
     - returns: The DPT type registered for the address, or .UNKNOWN if the address is not registered.
     */
    open static func getTypeForGroupAddress(_ address : KnxGroupAddress) -> KnxTelegramType {
        
        if let address = registry[address] {
            return address
        }
        else {
            log.warning("Address not in registry: \(address)")
            return KnxTelegramType.unknown
        }
    }
    
    /**
     Register a DPT type for a group address.
     
     - parameter address: The group address to register a type for.
     - parameter type: The type to register.
     */
    open static func addTypeForGroupAddress(_ address : KnxGroupAddress,
                                              type : KnxTelegramType) {
        log.verbose("Adding address \(address.addressAsUInt16) to registry.")
        registry[address] = type
    }
    
    // MARK: Internal and private declarations
    fileprivate static let log = SwiftyBeaver.self
}

