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
open class KnxGroupAddress: Hashable {

    // MARK: Public API.

    /**
     initializer for the group address object.
     
     - parameter fromString: A string representation of the group address, in the form of "a/b/c".
     */
    public init(fromString: String) {

        let parts = fromString.components(separatedBy: "/")

        if let a = UInt16(parts[0]), let b = UInt16(parts[1]), let c = UInt16(parts[2]) {

            addressAsUInt16 = a << 11 | b << 8 | c

        } else {
            addressAsUInt16 = 0
        }

    }

    /**
     initializer for the group address object.

     - parameter fromUInt16: An UInt16 integer representing the group address.
     */
    public init(fromUInt16: UInt16) {

        addressAsUInt16 = fromUInt16

    }

    /**
     A read-only property returning a string representing the group address object.
     */
    open var string: String {

        let a: UInt16 = (addressAsUInt16 >> 11) & 0x0001F
        let b: UInt16 = (addressAsUInt16 >> 8) & 0x0007
        let c: UInt16 = addressAsUInt16 & 0x00FF

        return String.init(format: "%d/%d/%d", a, b, c)
    }

    /// A read-only property returning the 16bit representation of the group address.
    fileprivate(set) open var addressAsUInt16: UInt16

    /// A read-only property returning the hash value of the object.
    open var hashValue: Int {
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
