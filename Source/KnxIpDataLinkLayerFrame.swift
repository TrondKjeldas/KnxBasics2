//
//  KnxIpDataLinkLayerFrame.swift
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

/// Class representing a KNX Data Link Layer Frame.
open class KnxIpDataLinkLayerFrame {

    // MARK: Public API

    /// Default initializer.
    public init() {

        _header = nil
        _body = nil
    }

    public init(header: KnxNetIpHeader, body: [UInt8]?) {

        _header = header
        _body = body
    }

    public var payload: Data {

        guard  let _header = _header, let _body = _body else {
            return Data()
        }

        let data = _header.payload + Data(bytes: _body)
        log.debug("FRAME: \(data.hexEncodedString())")
        return data
    }

    // MARK: Internal and private declarations
    fileprivate var _header: KnxNetIpHeader?
    fileprivate var _body: [UInt8]?

    fileprivate let log = SwiftyBeaver.self
}
