//
//  KnxGroupAddress.swift
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

/// Class representing a KNX group address.
public class KnxGroupAddress : Hashable {
    
    // MARK: Public API.
    
    /**
     initializer for the group address object.
     
     - parameter fromString: A string representation of the group address, in the form of "a/b/c".
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
    
    /// A read-only property returning the 16bit representation of the group address.
    private(set) public var addressAsUInt16 : UInt16
    
    /// A read-only property returning the hash value of the object.
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
