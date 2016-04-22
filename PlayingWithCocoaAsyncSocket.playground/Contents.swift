//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket


public class SendNet: NSObject, GCDAsyncSocketDelegate {
    
    var socket:GCDAsyncSocket! = nil
    var socket2:GCDAsyncSocket! = nil
    
    func setupConnection(){
        
        if (socket == nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        } else {
            socket.disconnect()
        }
        
        let port:UInt16 = 80
        let host = "192.168.1.7"
        do {
            
             try socket.connectToHost(host, onPort: port)
            
            }
        catch let e {
            print(e)
        }
        
    }
    
    func startServer(port:UInt16) {
        
        if (socket == nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        } else {
            socket.disconnect()
        }
        
        do {
            try socket.acceptOnPort(port)
        } catch let e {
            print("Catched: \(e)")
        }
    }

    public func socket(socket : GCDAsyncSocket, didAcceptNewSocket: GCDAsyncSocket) {
        
        socket2 = socket
        print("Accepted: \(socket.connectedHost) from port \(socket.connectedPort).")
        
        let string = "THIS IS SENT\n\n"
        let msgData = string.dataUsingEncoding(NSUTF8StringEncoding)
        socket2.writeData(msgData, withTimeout: -1.0, tag: 0)
        socket2.readDataWithTimeout(-1.0, tag: 0)
    }
    
    public func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        print("Connected to \(host) on port \(p).")
        
        self.socket = socket
        
        getSystemInfo()
        getSystemStatus()
    }
    

    func send(msgBytes: [UInt8]) {
        
        let msgData = NSData(bytes: msgBytes, length: msgBytes.count)
        socket.writeData(msgData, withTimeout: -1.0, tag: 0)
        socket.readDataWithTimeout(-1.0, tag: 0)
        
    }
    
    func getSystemInfo() {
        
        let sendBytes:[UInt8] = [0x0, 0x1, 0x2, 0x3]
        send(sendBytes)
        
    }
    
    func getSystemStatus() {
        
        let sendBytes:[UInt8] = [0x4, 0x5, 0x6, 0x7]
        send(sendBytes)
        print("ccc")
        
    }
    
    
    public func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int){
        
        let msgData = NSMutableData()
        msgData.setData(data)
        
        var msgType:UInt16 = 0
        msgData.getBytes(&msgType, range: NSRange(location: 2,length: 1))
        
        print(msgType)
        
    }
}

class MyDelegateClass : NSObject, GCDAsyncSocketDelegate {

    var socket:GCDAsyncSocket! = nil

     func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
    //func didConnectToHost(socket:GCDAsyncSocket, host:NSString, port:UInt16) {
    
        print("connect!")
        print("isConnected: \(socket.isConnected)")
        self.socket = socket
        let sendBytes:[UInt8] =  [0x4, 0x5, 0x6, 0x7]
        send(sendBytes)
    }
    
    func send(msgBytes: [UInt8]) {
        
        let string = "GET / HTTP/1.1 \nhost: xxx\n\n"
        let msgData = string.dataUsingEncoding(NSUTF8StringEncoding)
        socket.writeData(msgData, withTimeout: -1.0, tag: 0)
        socket.readDataWithTimeout(-1.0, tag: 20)
        
        socket.disconnectAfterReading()
    }

    func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int) {
        
        let ss = NSString(data:data, encoding:NSUTF8StringEncoding)
        
        print("GOT:\n\(ss)\n with tag: \(tag)")
        
            print("isConnected: \(socket.isConnected)")
    }

}

let md = MyDelegateClass()
let md2 = SendNet()
//md2.startServer(18002)

//md2.setupConnection()
//md2.getSystemStatus()

let s = GCDAsyncSocket(delegate: md, delegateQueue: dispatch_get_main_queue())

do {
    try s.connectToHost("zbox", onPort: 80)
    print("after")
} catch let e {
    print("Oops: \(e)")
}

let c = s.isConnected












