//
//  KnxRouterInterface.swift
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

import CocoaAsyncSocket
import SwiftyBeaver

/// Type of connection towards the KNX router
public enum ConnectionType {

    /// none         - No connection type
    case none

    /// tcpDirect    - TCP connection (likely KNXD/EIBD proprietary)
    case tcpDirect

    /// udpMulticast - UDP multicast, KNXNet/IP connection
    case udpMulticast
}

/// Class representing the interface towards the KNX router.
open class KnxRouterInterface: NSObject {

    // MARK: Public API.

    /// Property to set for selecting connetion type
    open static var connectionType: ConnectionType = .none

    /// Property for setting the IP address of the KNX router
    open static var routerIp: String?

    /// Property for setting the port to connect to the KNX router on
    /// (defaults to port 6720.)
    open static var routerPort: UInt16 = 6720

    /// Property for setting the multicast group to join
    open static var multicastGroup: String?

    /// Property for setting the port for the multicast group
    open static var multicastPort: UInt16 = 3671

    /** Factory function to return an instance of a KnxRouterInterface.

        - In tcpDirect mode each call returns a new instance, while
        - in udpMulticast mode every call returns the same shared instance.
     */
    open static func getKnxRouterInstance() -> KnxRouterInterface? {

        switch KnxRouterInterface.connectionType {

        case .tcpDirect:
            return KnxRouterInterface()

        case .udpMulticast:
            return KnxRouterInterface.sharedInstance

        default:
            SwiftyBeaver.self.error("Connection type not set!")
            return nil
        }
    }

    /**
     Connect to a KNX router.

     - throws: UnableToConnectToRouter
     */

    open func connect() throws {

        switch KnxRouterInterface.connectionType {

        case .tcpDirect:

            try connectTcp()

        case .udpMulticast:

            DispatchQueue.once(block: {
                print("once")
                try! joinMulticastGroup()
            })

        default:
            log.warning("Connection type note set!")
        }
    }

    /**
     Disconnect from a KNX.
     */
    open func disconnect() {

        if socket.isConnected {

            socket.delegate = nil
            socket.disconnect()
        }

        if KnxRouterInterface.connectionType == .udpMulticast {

            DispatchQueue.once(block: {
                try! udpSocket.leaveMulticastGroup(KnxRouterInterface.multicastGroup!)
            })
        }
    }

    /**
     Subscribe for a group address.

     - parameter address: The group address to subscrive to.
     */
    open func subscribeFor(address: KnxGroupAddress,
                           responseHandler: KnxTelegramResponseHandlerDelegate) {

        subscriptionMap[address] = responseHandler

        if KnxRouterInterface.connectionType == .tcpDirect {
            submit(telegram: KnxTelegramFactory.createSubscriptionRequest(groupAddress: address))
        }
    }

    /**
     Send a write request telegram to a group address.
     
     - parameter to: The group address to send to
     - parameter type: The DPT to send
     - parameter value: The value to send
     */

    open func sendWriteRequest(to: KnxGroupAddress, type: KnxTelegramType, value:Any) {

        switch type {
        case .dpt10_001:
            let val = value as! Int
            try! submit(telegram: KnxTelegramFactory.createWriteRequest(to: to,
                                                                        type: .dpt1_xxx,
                                                                        value:val))

        case .dpt5_001:

            let val = value as! Int
            try! submit(telegram: KnxTelegramFactory.createWriteRequest(to: to,
                                                                        type: .dpt5_001,
                                                                        value:val))

        default:
            log.error("Type mot supported: \(type)")
            break
        }
    }

    /**
     Send a read request telegram to a group address.
     */

    open func sendReadRequest(to: KnxGroupAddress) {

        submit(telegram: KnxTelegramFactory.createReadRequest(to: to))
    }

    // MARK: Internal and private declarations.

    /**
     Initializer for the router interface object.

     */
    private override init() {

        super.init()

        switch KnxRouterInterface.connectionType {

        case .tcpDirect:
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        case .udpMulticast:
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

        default:
            log.error("Connection type not set!")
        }
    }

    /**
     Submit a telegram for transmission.
     
     - parameter telegram: The telegram to transmit.
     */
    private func submit(telegram: KnxTelegram) {

        switch KnxRouterInterface.connectionType {
        case .tcpDirect:

            let msgData = Data(bytes: telegram.payload)

            log.info("SEND: \(msgData)")

            socket.write(msgData, withTimeout: -1.0, tag: 0)

            written += telegram.payload.count

        case .udpMulticast:

            let hdr = KnxNetIpHeader(asType: .routingIndication, withLength: telegram.payload.count)
            let frame = KnxIpDataLinkLayerFrame(header: hdr, body: telegram.payload)

            log.info("SEND: \(frame.payload.hexEncodedString())")

            udpSocket.send(frame.payload,
                           toHost: KnxRouterInterface.multicastGroup!,
                           port: KnxRouterInterface.multicastPort,
                           withTimeout: -1.0, tag: 0)

        default:
            log.warning("cant send because not conected")
        }
    }

    fileprivate var socket: GCDAsyncSocket! = nil
    fileprivate var udpSocket: GCDAsyncUdpSocket! = nil

    private static let sharedInstance: KnxRouterInterface = KnxRouterInterface()

    private var written: Int = 0
    fileprivate var readCount: Int = 0

    fileprivate var telegramData = NSMutableData()

    fileprivate var responseHandler: KnxTelegramResponseHandlerDelegate?

    fileprivate var subscriptionMap: [KnxGroupAddress : KnxTelegramResponseHandlerDelegate] = [:]

    fileprivate let log = SwiftyBeaver.self
}

extension KnxRouterInterface : GCDAsyncSocketDelegate {

    /**
     Connect to a KNX router over TCP.

     - throws: UnableToConnectToRouter
     */
    fileprivate func connectTcp() throws {

        if !socket.isConnected {

            socket.delegate = self

            do {
                try socket.connect(toHost: KnxRouterInterface.routerIp!,
                                   onPort: KnxRouterInterface.routerPort)

                log.verbose("after")
            } catch let e {

                log.error("Oops: \(e)")

                throw KnxException.unableToConnectToRouter
            }

        } else {

            log.warning("socket already connected")
        }
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon connection.

     - parameter socket: The socket that did connect.
     - parameter didConnectToHost: The name of the host that it has connected to.
     - parameter port: The port that was connected on.
     */
    @objc open func socket(_ socket: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {

        log.verbose("isConnected: \(socket.isConnected)")

        // Read first header
        socket.readData(toLength: 2, withTimeout:-1.0, tag: 0)
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon reception of data.

     - parameter socket: The socket that did connect.
     - parameter didReadData: The received data.
     - parameter withTag: The tag value supplied in the request to read.
     */
    @objc open func socket(_ socket: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {

        if tag == 0 {

            // Got header, two first bytes

            let msgLen: UInt16 = UInt16(data[0]) << 8 | UInt16(data[1])

            log.debug("LEN: \(msgLen)")

            telegramData.setData(data)
            socket.readData(toLength: UInt(msgLen), withTimeout:-1.0, buffer:telegramData, bufferOffset:2, tag: 1)

        } else {

            // Got remaining part of telegram

            readCount += 1

            log.info("GOT: \(telegramData)")

            if telegramData.length > 4 {

                var dataBytes: [UInt8] = [UInt8](repeating: 0, count: telegramData.length)

                telegramData.getBytes(&dataBytes, length: dataBytes.count)

                let telegram = KnxTelegram(bytes: dataBytes)

                // In theory there should be only one subscriber present, since
                // there is one KnxRouterInterface instance per group address in
                // .tcpDirect mode. But call all of them just to be sure.
                for handler in subscriptionMap {
                    handler.value.subscriptionResponse(sender:self, telegram:telegram)
                }
            }

            // Next header
            socket.readData(toLength: 2, withTimeout:-1.0, tag: 0)
        }
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon reception of data.

     - parameter socket: The socket that did connect.
     - parameter err: If the socket disconneted because of an error.
     */
    @objc open func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {

        log.error("Socket disconnected: \(String(describing: err))")
    }
}

extension KnxRouterInterface : GCDAsyncUdpSocketDelegate {

    /**
     Join a KNX multicast group at the specified address and port.

     - parameter ipAddress: The IP address to connect to.
     - parameter onPort: The port to connect to. Default is port 6720.

     - throws: UnableToConnectToRouter
     */
    fileprivate func joinMulticastGroup() throws {

        if let udpSocket = udpSocket,
            let group = KnxRouterInterface.multicastGroup {

            udpSocket.setIPv6Enabled(false)

            do {
                try udpSocket.enableBroadcast(true)
                try udpSocket.enableReusePort(true)
                try udpSocket.bind(toPort: KnxRouterInterface.multicastPort)
                try udpSocket.joinMulticastGroup(group, onInterface: "en0")
                try udpSocket.beginReceiving()

            } catch let error as NSError {
                log.error("failed: \(error)")
                throw KnxException.unableToConnectToRouter
            }
        } else {
            log.error("socket or group not initialized")
            throw KnxException.unableToConnectToRouter
        }
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon reception of data.

     - parameter sock: The socket that the data was received on.
     - parameter data: The received data.
     - parameter address: The source address.
     - parameter filterContext: The filter context used.

     - parameter err: If the socket disconneted because of an error.
     */
    open func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data,
                        fromAddress address: Data, withFilterContext filterContext: Any?) {

        log.info("GOT: \(data.hexEncodedString())")

        let dataBytes: [UInt8] = Array(data.subdata(in: 9..<data.count))

        let telegram = KnxTelegram(bytes: dataBytes)

        log.info("address: \(telegram.getGroupAddress().string)")

        if telegram.isWriteRequestOrValueResponse {
            subscriptionMap[telegram.getGroupAddress()]?.subscriptionResponse(sender:self,
                                                                              telegram:telegram)
        }
    }
}
