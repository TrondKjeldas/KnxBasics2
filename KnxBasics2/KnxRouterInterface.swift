//
//  KnxRouterInterfaceImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

import CocoaAsyncSocket

public class KnxRouterInterfaceImplementation : NSObject, GCDAsyncSocketDelegate, KnxRouterInterface {
    
    private var socket:GCDAsyncSocket! = nil
    private var written:Int = 0
    private var readCount:Int = 0
    
    private var telegramData = NSMutableData()
    
    private var responseHandler : KnxResponseHandlerDelegate? = nil
    
    required public init(responseHandler : KnxResponseHandlerDelegate) {
        
        super.init()
        self.responseHandler = responseHandler
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
    }
    
    public func connectTo(ipAddress:String, onPort:UInt16 = 6720) {
        
        
        do {
            try socket.connectToHost("zbox", onPort: onPort)
            print("after")
        } catch let e {
            print("Oops: \(e)")
        }
    }
    
    public func submit(telegram:KnxTelegram) {
        
        let msgData = NSData(bytes: telegram.payload, length: telegram.payload.count)
        print("SEND: \(msgData)")
        socket.writeData(msgData, withTimeout: -1.0, tag: 0)
        
        written += telegram.payload.count
    }
    
    @objc public func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        
        print("isConnected: \(socket.isConnected)")
        
        // Read first header
        socket.readDataToLength(2, withTimeout:-1.0, tag: 0)
    }
    
    
    @objc public func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int) {
        
        if(tag == 0) {
            
            // Got header, two first bytes
            
            telegramData.setData(data)
            
            var msgLenL:UInt8 = 0
            var msgLenH:UInt8 = 0
            
            telegramData.getBytes(&msgLenH, range: NSRange(location: 0,length: 1))
            telegramData.getBytes(&msgLenL, range: NSRange(location: 1,length: 1))
            
            let msgLen:UInt16 = UInt16(msgLenH) << 8 | UInt16(msgLenL)
            
            print("LEN: \(msgLen)")
            
            socket.readDataToLength(UInt(msgLen), withTimeout:-1.0, buffer:telegramData, bufferOffset:2, tag: 1)
            
        } else {
            
            // Got remaining part of telegram
            
            readCount += 1
            
            print("GOT: \(telegramData)")
            
            if(telegramData.length > 4) {
                
                var dataBytes:[UInt8] = [UInt8](count:telegramData.length, repeatedValue:0)
                telegramData.getBytes(&dataBytes, length: dataBytes.count)
                self.responseHandler?.subscriptionResponse(self, telegram:KnxTelegramImplementation(bytes: dataBytes))
                
            }
            
            // Next header
            socket.readDataToLength(2, withTimeout:-1.0, tag: 0)
        }
    }
    
    public func show() {
        print("Connected? \(socket.isConnected)")
        print("Written? \(written)")
    }
}
