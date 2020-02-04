//
//  KnxTelegramFactory.swift
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

/// Factory class to create KNX telegrams of various type.
open class KnxTelegramFactory {

    // MARK: Public API

    /**
     Create a subscription request.

     - parameter groupAddress: The group address to subscribe to.

     - returns: A subscription request telegram, ready to be sent.
     */
    public static func createSubscriptionRequest(groupAddress: KnxGroupAddress) -> KnxTelegram {

        let addrLow8 = UInt8(truncatingIfNeeded:(groupAddress.addressAsUInt16 & 0xFF))
        let addrHigh8 = UInt8(truncatingIfNeeded:(groupAddress.addressAsUInt16 >> 8))

        var bytes: [UInt8] = [UInt8](repeating: 0, count: 7)
        // Length...
        bytes[0] = 0
        bytes[1] = 5
        // Content
        bytes[2] = 0
        bytes[3] = 34
        bytes[4] = addrHigh8
        bytes[5] = addrLow8
        bytes[6] = 0x00

        return KnxTelegram(bytes: bytes)
    }

    /**
     Create a read request.
     
     - returns: A read request telegram, ready to be sent.
     */
    public static func createReadRequest(to: KnxGroupAddress) -> KnxTelegram {

        var bytes: [UInt8]

        switch KnxRouterInterface.connectionType {
        case .tcpDirect:
            bytes = [UInt8](repeating: 0, count: 6)
            // Length...
            bytes[0] = 0
            bytes[1] = 4
            // Content
            bytes[2] = 0
            bytes[3] = 37
            bytes[4] = 0
            bytes[5] = 0

        case .udpMulticast:
            bytes = [UInt8](repeating: 0, count: 11)
            bytes[0] = 0x29
            bytes[1] = 0x00
            bytes[2] = 0xBC
            bytes[3] = 0xD0
            bytes[4] = UInt8((KnxRouterInterface.knxSourceAddr!.addressAsUInt16 >> 8) & 0xFF) // src addr
            bytes[5] = UInt8(KnxRouterInterface.knxSourceAddr!.addressAsUInt16 & 0xFF) // src addr

            bytes[6] = UInt8((to.addressAsUInt16 >> 8) & 0xFF) // dst addr
            bytes[7] = UInt8(to.addressAsUInt16 & 0xFF)        // dst addr

            bytes[8] = 0x01 // NPDU len
            bytes[9] = 0x00
            bytes[10] = 0x00
        default:
            bytes = [UInt8](repeating: 0, count: 6)
            //log.warning("Connection not set")
        }

        return KnxTelegram(bytes: bytes)
    }

    /**
     Create a write request telegram.

     - parameter type: DPT type.
     - parameter value: The value to write, as an integer.

     - returns: A telegram, ready to be sent.
     - throws: UnknownTelegramType     
     */
    public static func createWriteRequest(to: KnxGroupAddress,
                                        type: KnxTelegramType,
                                        value: Int) throws -> KnxTelegram {

        switch type {

        case .dpt1_xxx:

            return createDpt1_xxxWriteRequest(to: to, value: value)

        case .dpt5_001:

            return createDpt5_001WriteRequest(to: to, value: value)

        default:
            throw KnxException.unknownTelegramType
        }
    }

    /**
     Create a write request telegram for DPT5_001.

     - parameter to: Group address to write to.
     - parameter value: The value to write, as an integer.

     - returns: A telegram, ready to be sent.
     */
    private static func createDpt5_001WriteRequest(to: KnxGroupAddress,
                                                   value: Int) -> KnxTelegram {

        var bytes: [UInt8]

        switch KnxRouterInterface.connectionType {
        case .tcpDirect:
            bytes = [UInt8](repeating: 0, count: 7)

            // Length...
            bytes[0] = 0
            bytes[1] = 5
            // Content
            bytes[2] = 0
            bytes[3] = 37
            bytes[4] = 0
            bytes[5] = 0x80
            bytes[6] = UInt8(truncatingIfNeeded:((value * 255) / 100)) /* Convert range from 0-100 to 8bit */

        case .udpMulticast:
            bytes = [UInt8](repeating: 0, count: 12)
            bytes[0] = 0x29
            bytes[1] = 0x00
            bytes[2] = 0xBC
            bytes[3] = 0xD0
            bytes[4] = UInt8((KnxRouterInterface.knxSourceAddr!.addressAsUInt16 >> 8) & 0xFF) // src addr
            bytes[5] = UInt8(KnxRouterInterface.knxSourceAddr!.addressAsUInt16 & 0xFF) // src addr

            bytes[6] = UInt8((to.addressAsUInt16 >> 8) & 0xFF) // dst addr
            bytes[7] = UInt8(to.addressAsUInt16 & 0xFF)        // dst addr

            bytes[8] = 0x02 // NPDU len
            bytes[9] = 0x00
            bytes[10] = 0x80
            bytes[11] = UInt8(truncatingIfNeeded:((value * 255) / 100)) /* Convert range from 0-100 to 8bit */

        default:
            bytes = [UInt8](repeating: 0, count: 6)
            //log.warning("Connection not set")
        }

        return KnxTelegram(bytes: bytes)
    }

    /**
     Create a write request telegram for DPT1_xxx.

     - parameter to: Group address to write to.
     - parameter value: The value to write, as an integer.

     - returns: A telegram, ready to be sent.
     */
    private static func createDpt1_xxxWriteRequest(to: KnxGroupAddress,
                                                   value: Int) -> KnxTelegram {

        var bytes: [UInt8]

        switch KnxRouterInterface.connectionType {
        case .tcpDirect:
            bytes = [UInt8](repeating: 0, count: 6)
            // Length...
            bytes[0] = 0
            bytes[1] = 4
            // Content
            bytes[2] = 0
            bytes[3] = 37
            bytes[4] = 0
            bytes[5] = UInt8(truncatingIfNeeded:value) | 0x80

        case .udpMulticast:
            bytes = [UInt8](repeating: 0, count: 11)
            bytes[0] = 0x29
            bytes[1] = 0x00
            bytes[2] = 0xBC
            bytes[3] = 0xD0
            bytes[4] = UInt8((KnxRouterInterface.knxSourceAddr!.addressAsUInt16 >> 8) & 0xFF) // src addr
            bytes[5] = UInt8(KnxRouterInterface.knxSourceAddr!.addressAsUInt16 & 0xFF) // src addr

            bytes[6] = UInt8((to.addressAsUInt16 >> 8) & 0xFF) // dst addr
            bytes[7] = UInt8(to.addressAsUInt16 & 0xFF)        // dst addr

            bytes[8] = 0x01 // NPDU len
            bytes[9] = 0x00
            bytes[10] = UInt8(truncatingIfNeeded:value) | 0x80

        default:
            bytes = [UInt8](repeating: 0, count: 6)
            //log.warning("Connection not set")
        }

        return KnxTelegram(bytes: bytes)
    }
}
