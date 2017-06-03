//
//  KnxNetIpHeader.swift
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

/// Class representing a KNXnet/IP header.
open class KnxNetIpHeader {

    // MARK: Public API

    public enum ServiceTypeIdentifier: UInt16 {

        case Unknown = 0x0000
        case RoutingIndication = 0x0530
        case RoutingBusy = 0x0531
        case RoutingLostMessage = 0x0532

        func highByte() -> UInt8 {
            return UInt8((self.rawValue >> 8) & 0x00FF)
        }
        func lowByte() -> UInt8 {
            return UInt8(self.rawValue & 0x00FF)
        }
    }

    /// Default initializer.
    public init() {

      _hdrLength = 6
      _protocolVersion = 0x10
      _serviceTypeIdentifier = .Unknown
      _totalLength = 6
    }

    /// Convinience initializer.
    public convenience init(asType type: ServiceTypeIdentifier, withLength length: Int = 0) {

        self.init()
        _serviceTypeIdentifier = type
        _totalLength = 6 + UInt16(length)
    }

    public var payload: Data {

        let data = Data(bytes: [ _hdrLength, _protocolVersion,
                                 _serviceTypeIdentifier.highByte(), _serviceTypeIdentifier.lowByte(),
                                 UInt8(_totalLength >> 8), UInt8(_totalLength)])
        log.debug("HDR: \(data.hexEncodedString())")
        return data
    }

    // MARK: Internal and private declarations

    fileprivate var _hdrLength: UInt8
    fileprivate var _protocolVersion: UInt8
    fileprivate var _serviceTypeIdentifier: ServiceTypeIdentifier
    fileprivate var _totalLength: UInt16

    fileprivate let log = SwiftyBeaver.self
}
