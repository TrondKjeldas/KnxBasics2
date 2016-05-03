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
public class KnxRouterInterface : NSObject, GCDAsyncSocketDelegate {
    
    // MARK: Public API.
    
    /**
     Initializer for the router interface object.
     
     - parameter responseHandler: The delegate object handling received telegrams.
     
     - returns: Nothing.
     */
    public init(responseHandler : KnxTelegramResponseHandlerDelegate) {
        
        super.init()
        
        self.responseHandler = responseHandler
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
    }
    
    /**
     Connect to a KNX router at the specified address and port.
     
     - parameter ipAddress: The IP address to connect to.
     - parameter onPort: The port to connect to. Default is port 6720.
     
     - returns: Nothing.
     */
    public func connect() throws {
        
        
        do {
            try socket.connectToHost(KnxRouterInterface.routerIp,
                                     onPort: KnxRouterInterface.routerPort)
            log.verbose("after")
        } catch let e {
            
            log.error("Oops: \(e)")

            throw KnxException.UnableToConnectToRouter
        }
    }
    
    /**
     Submit a telegram for transmission.
     
     - parameter telegram: The telegram to transmit.
     
     - returns: Nothing.
     */
    public func submit(telegram:KnxTelegram) {
        
        let msgData = NSData(bytes: telegram.payload, length: telegram.payload.count)
        log.info("SEND: \(msgData)")
        socket.writeData(msgData, withTimeout: -1.0, tag: 0)
        
        written += telegram.payload.count
    }
    
    /**
     Response handler, called from the CocoaAsyncSocket framework upon connection.
     
     - parameter socket: The socket that did connect.
     - parameter didConnectToHost: The name of the host that it has connected to.
     - parameter port: The port that was connected on.
     
     - returns: Nothing.
     */
    @objc public func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        
        log.verbose("isConnected: \(socket.isConnected)")
        
        // Read first header
        socket.readDataToLength(2, withTimeout:-1.0, tag: 0)
    }

    /**
     Response handler, called from the CocoaAsyncSocket framework upon reception of data.
     
     - parameter socket: The socket that did connect.
     - parameter didReadData: The received data.
     - parameter withTag: The tag value supplied in the request to read.
     
     - returns: Nothing.
     */
    @objc public func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int) {
        
        if(tag == 0) {
            
            // Got header, two first bytes
            
            telegramData.setData(data)
            
            var msgLenL:UInt8 = 0
            var msgLenH:UInt8 = 0
            
            telegramData.getBytes(&msgLenH, range: NSRange(location: 0,length: 1))
            telegramData.getBytes(&msgLenL, range: NSRange(location: 1,length: 1))
            
            let msgLen:UInt16 = UInt16(msgLenH) << 8 | UInt16(msgLenL)
            
            log.debug("LEN: \(msgLen)")
            
            socket.readDataToLength(UInt(msgLen), withTimeout:-1.0, buffer:telegramData, bufferOffset:2, tag: 1)
            
        } else {
            
            // Got remaining part of telegram
            
            readCount += 1
            
            log.info("GOT: \(telegramData)")
            
            if(telegramData.length > 4) {
                
                var dataBytes:[UInt8] = [UInt8](count:telegramData.length, repeatedValue:0)
                
                telegramData.getBytes(&dataBytes, length: dataBytes.count)
                
                let telegram = KnxTelegram(bytes: dataBytes)
                
                if telegram.isWriteRequestOrValueResponse {
                    
                    self.responseHandler?.subscriptionResponse(self, telegram:telegram)
                }
            }
            
            // Next header
            socket.readDataToLength(2, withTimeout:-1.0, tag: 0)
        }
    }
    
    /// Property for setting the IP address of the KNX router
    public static var routerIp : String?
    
    /// Property for setting the port to connect to the KNX router on.
    /// (defaults to port 6720)
    public static var routerPort : UInt16 = 6720
    
    // MARK: Internal and private declarations.
    
    private var socket:GCDAsyncSocket! = nil
    private var written:Int = 0
    private var readCount:Int = 0
    
    private var telegramData = NSMutableData()
    
    private var responseHandler : KnxTelegramResponseHandlerDelegate? = nil
    
    private let log = SwiftyBeaver.self
}
