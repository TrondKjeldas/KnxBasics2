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

/// Class representing the interface towards the KNX router.
open class KnxRouterInterface : NSObject, GCDAsyncSocketDelegate {
    
    // MARK: Public API.

    /**
     Initializer for the router interface object.

     - parameter responseHandler: The delegate object handling received telegrams.
     */
    public init(responseHandler : KnxTelegramResponseHandlerDelegate) {
        
        super.init()
        
        self.responseHandler = responseHandler

        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }

    public enum ConnectionType {

        case none

        case tcpDirect

        case udpMulticast
    }

    /**
     Connect to a KNX router.

     - throws: UnableToConnectToRouter
     */

    open func connect(type:ConnectionType) throws {

        switch type {

        case .tcpDirect:

            try connectTcp()

        case .udpMulticast:

            try joinMulticastGroup()

        default:
            log.warning("cant send because not conected")
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
    }

    /**
     Submit a telegram for transmission.
     
     - parameter telegram: The telegram to transmit.
     */
    open func submit(telegram:KnxTelegram) {
        
        let msgData = Data(bytes: UnsafePointer<UInt8>(telegram.payload), count: telegram.payload.count)
        log.info("SEND: \(msgData)")

        switch connectionType {
        case .tcpDirect:
            socket.write(msgData, withTimeout: -1.0, tag: 0)

            written += telegram.payload.count

        case .udpMulticast:
            udpSocket.send(msgData, withTimeout: -1.0, tag: 0)

        default:
            log.warning("cant send because not conected")
        }
    }

    /**
     Join a KNX multicast group at the specified address and port.

     - parameter ipAddress: The IP address to connect to.
     - parameter onPort: The port to connect to. Default is port 6720.

     - throws: UnableToConnectToRouter
     */
    private func joinMulticastGroup() throws {

        if connectionType == .none {

            if let udpSocket = self.udpSocket,
                let group = KnxRouterInterface.multicastGroup {

                udpSocket.setIPv6Enabled(false)

                do {
                    try udpSocket.enableBroadcast(true)
                    try udpSocket.enableReusePort(true)
                    try udpSocket.bind(toPort: KnxRouterInterface.multicastPort)
                    try udpSocket.joinMulticastGroup(group, onInterface: "en0")
                    try udpSocket.beginReceiving()

                    connectionType = .udpMulticast

                } catch let error as NSError {
                    print("failed: \(error)")
                    throw KnxException.unableToConnectToRouter
                }
            } else {
                log.error("socket or group not initialized")
                throw KnxException.unableToConnectToRouter
            }
        } else {
            log.error("already connected")
            throw KnxException.unableToConnectToRouter
        }
    }

    /**
     Connect to a KNX router over TCP.

     - throws: UnableToConnectToRouter
     */
    private func connectTcp() throws {

        if connectionType == .none {
            if !socket.isConnected {

                socket.delegate = self

                do {
                    try socket.connect(toHost: KnxRouterInterface.routerIp!,
                                       onPort: KnxRouterInterface.routerPort)

                    connectionType = .tcpDirect

                    log.verbose("after")
                } catch let e {

                    log.error("Oops: \(e)")

                    throw KnxException.unableToConnectToRouter
                }
                
            } else {
                
                log.warning("socket already connected")
            }
        } else {
            log.error("already connected")
        }
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon connection.
     
     - parameter socket: The socket that did connect.
     - parameter didConnectToHost: The name of the host that it has connected to.
     - parameter port: The port that was connected on.
     */
    @objc open func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        
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
    @objc open func socket(_ socket : GCDAsyncSocket, didRead data:Data, withTag tag:Int) {
        
        if(tag == 0) {
            
            // Got header, two first bytes
            
            telegramData.setData(data)
            
            var msgLenL:UInt8 = 0
            var msgLenH:UInt8 = 0
            
            telegramData.getBytes(&msgLenH, range: NSRange(location: 0,length: 1))
            telegramData.getBytes(&msgLenL, range: NSRange(location: 1,length: 1))
            
            let msgLen:UInt16 = UInt16(msgLenH) << 8 | UInt16(msgLenL)
            
            log.debug("LEN: \(msgLen)")
            
            socket.readData(toLength: UInt(msgLen), withTimeout:-1.0, buffer:telegramData, bufferOffset:2, tag: 1)
            
        } else {
            
            // Got remaining part of telegram
            
            readCount += 1
            
            log.info("GOT: \(telegramData)")
            
            if(telegramData.length > 4) {
                
                var dataBytes:[UInt8] = [UInt8](repeating: 0, count: telegramData.length)
                
                telegramData.getBytes(&dataBytes, length: dataBytes.count)
                
                let telegram = KnxTelegram(bytes: dataBytes)
                
                if telegram.isWriteRequestOrValueResponse {
                    
                    self.responseHandler?.subscriptionResponse(sender:self, telegram:telegram)
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
    
    /// Property for setting the IP address of the KNX router
    open static var routerIp : String?
    
    /// Property for setting the port to connect to the KNX router on
    /// (defaults to port 6720.)
    open static var routerPort : UInt16 = 6720

    open static var multicastGroup : String?
    open static var multicastPort : UInt16 = 3671

    // MARK: Internal and private declarations.
    
    private var socket:GCDAsyncSocket! = nil
    private var udpSocket: GCDAsyncUdpSocket! = nil

    private var connectionType: ConnectionType = .none

    private var written:Int = 0
    private var readCount:Int = 0
    
    private var telegramData = NSMutableData()
    
    fileprivate var responseHandler : KnxTelegramResponseHandlerDelegate? = nil
    
    private let log = SwiftyBeaver.self
}

extension KnxRouterInterface : GCDAsyncUdpSocketDelegate {

    open func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {


        let telegramData = NSMutableData()

        telegramData.setData(data)

        print("GOT: \(telegramData)")

        var dataBytes:[UInt8] = [UInt8](repeating: 0, count: telegramData.length - 9)

        telegramData.getBytes(&dataBytes, range: NSRange(location: 9,length: telegramData.length - 9))


        let telegram = KnxTelegram(bytes: dataBytes)

        print("address: \(telegram.getGroupAddr())")
        if telegram.getGroupAddr() == "1/0/14" {
            let val:Int = try! telegram.getValueAsType(type: .dpt1_xxx)
            print("value: \(val)")
        }

        if telegram.isWriteRequestOrValueResponse {

            self.responseHandler?.subscriptionResponse(sender:self, telegram:telegram)
        }
    }

    public func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        print("connected")
    }

    public func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print("did not connect")
    }

    public  func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("did not send data, error: \(error)")
    }

    public func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("did send data")
    }

    public func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        print("did close")
    }
    
    
}

