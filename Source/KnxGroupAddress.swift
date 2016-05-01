//
//  KnxGroupAddress.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

/// Class representing a KNX group address.
public class KnxGroupAddress : Hashable {
    
    // MARK: Public API.
    
    /**
     initializer for the group address object.
     
     - parameter fromString: A string representation of the group address, in the form of "a/b/c".
     
     - returns: Nothing.
     */
    public init(fromString:String) {
        
        
        let parts = fromString.componentsSeparatedByString("/")
        
        if let a = UInt16(parts[0]), b = UInt16(parts[1]), c = UInt16(parts[2]){
            
            addressAsUInt16 = a << 11 | b << 8 | c
            
        } else
        {
            addressAsUInt16 = 0
        }
        
    }
    
    /// A read-only attribute returning the 16bit representation of the group address.
    private(set) public var addressAsUInt16 : UInt16
    
    /// A read-only attribute returning the hash value of the object.
    public var hashValue: Int {
        return Int(addressAsUInt16)
    }
}

/**
 Equality operator for the KnxGroupAddress class.
 
 - parameter lhs: The left-hand-side of the comparision.
 - parameter rhs: The right-hand-side of the comparision.
 
 - returns: True if the objects are equal, otherwise false.
 */
public func ==(lhs: KnxGroupAddress,
               rhs: KnxGroupAddress) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
