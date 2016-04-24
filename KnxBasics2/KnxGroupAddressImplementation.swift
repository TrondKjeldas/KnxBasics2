//
//  KnxGroupAddressImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxGroupAddressImplementation : KnxGroupAddress {
    
    required public init(fromString:String) {
        
        
        let parts = fromString.componentsSeparatedByString("/")

        if let a = UInt16(parts[0]), b = UInt16(parts[1]), c = UInt16(parts[2]){
            
            addressAsUInt16 = a << 11 | b << 8 | c

        } else
        {
            addressAsUInt16 = 0
        }

    }
    
    public var addressAsUInt16 : UInt16
}
