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
//: Playground - noun: a place where people can play

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket


public class SendNet: NSObject, GCDAsyncSocketDelegate {
    
    var socket:GCDAsyncSocket! = nil
    var socket2:GCDAsyncSocket! = nil
    
    func setupConnection(){
        
        if (socket == nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        } else {
            socket.disconnect()
        }
        
        let port:UInt16 = 80
        let host = "192.168.1.7"
        do {
            
             try socket.connect(toHost: host, onPort: port)
            
            }
        catch let e {
            print(e)
        }
        
    }
    
    func startServer(port:UInt16) {
        
        if (socket == nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        } else {
            socket.disconnect()
        }
        
        do {
            try socket.accept(onPort: port)
        } catch let e {
            print("Catched: \(e)")
        }
    }

    public func socket(_ socket : GCDAsyncSocket, didAcceptNewSocket: GCDAsyncSocket) {
        
        socket2 = socket
        print("Accepted: \(socket.connectedHost) from port \(socket.connectedPort).")
        
        let string = "THIS IS SENT\n\n"
        let msgData = string.data(using: String.Encoding.utf8)
        socket2.write(msgData!, withTimeout: -1.0, tag: 0)
        socket2.readData(withTimeout: -1.0, tag: 0)
    }
    
    public func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        print("Connected to \(host) on port \(p).")
        
        self.socket = socket
        
        getSystemInfo()
        getSystemStatus()
    }
    

    func send(msgBytes: [UInt8]) {
        
        let msgData = NSData(bytes: msgBytes, length: msgBytes.count)
        socket.write(msgData as Data, withTimeout: -1.0, tag: 0)
        socket.readData(withTimeout: -1.0, tag: 0)
        
    }
    
    func getSystemInfo() {
        
        let sendBytes:[UInt8] = [0x0, 0x1, 0x2, 0x3]
        send(msgBytes: sendBytes)
        
    }
    
    func getSystemStatus() {
        
        let sendBytes:[UInt8] = [0x4, 0x5, 0x6, 0x7]
        send(msgBytes: sendBytes)
        print("ccc")
        
    }
    
    
    public func socket(_ socket : GCDAsyncSocket, didRead data:Data, withTag tag:Int){
        
        let msgData = NSMutableData()
        msgData.setData(data)
        
        var msgType:UInt16 = 0
        msgData.getBytes(&msgType, range: NSRange(location: 2,length: 1))
        
        print(msgType)
        
    }
}

class MyDelegateClass : NSObject, GCDAsyncSocketDelegate {

    var socket:GCDAsyncSocket! = nil

     func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
    //func didConnectToHost(socket:GCDAsyncSocket, host:NSString, port:UInt16) {
    
        print("connect!")
        print("isConnected: \(socket.isConnected)")
        self.socket = socket
        let sendBytes:[UInt8] =  [0x4, 0x5, 0x6, 0x7]
        send(msgBytes: sendBytes)
    }
    
    func send(msgBytes: [UInt8]) {
        
        let string = "GET / HTTP/1.1 \nhost: xxx\n\n"
        let msgData = string.data(using: String.Encoding.utf8)
        socket.write(msgData!, withTimeout: -1.0, tag: 0)
        socket.readData(withTimeout: -1.0, tag: 20)
        
        socket.disconnectAfterReading()
    }

    func socket(_ socket : GCDAsyncSocket, didRead data:Data, withTag tag:Int) {
        
        let ss = NSString(data:data, encoding:String.Encoding.utf8.rawValue)
        
        print("GOT:\n\(ss)\n with tag: \(tag)")
        
            print("isConnected: \(socket.isConnected)")
    }

}

let md = MyDelegateClass()
let md2 = SendNet()
//md2.startServer(18002)

//md2.setupConnection()
//md2.getSystemStatus()

let s = GCDAsyncSocket(delegate: md, delegateQueue: DispatchQueue.main)

do {
    try s.connect(toHost: "gax58", onPort: 80)
    print("after")
} catch let e {
    print("Oops: \(e)")
}

let c = s.isConnected












