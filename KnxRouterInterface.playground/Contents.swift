//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket

import KnxBasics2


let kr = KnxRouterInterfaceImplementation()
let kr2 = KnxRouterInterfaceImplementation()


kr.connectTo("zbox")

func mkAddr(addr:UInt16) -> [UInt8] {

    let address:UInt16 = 1 << 11 | 0 << 8 | addr
    
    let addrLow:UInt16 = (address & 0xFF)
    let addrHigh:UInt16 = (address >> 8)
    let addrLow8 = UInt8(truncatingBitPattern:addrLow)
    let addrHigh8 = UInt8(truncatingBitPattern:addrHigh)
    
    var bytes:[UInt8] = [UInt8](count:7, repeatedValue:0)
    bytes[4] = addrHigh8
    bytes[5] = addrLow8
    bytes[6] = 0x00;
    bytes[2] = 0;
    bytes[3] = 34;
    
    // Add length...
    bytes[0] = 0;
    bytes[1] = 5;
    
    return bytes
}
let bytes = mkAddr(16)
let kt = KnxTelegramImplementation(bytes: bytes)
kr.submit(kt)
//kr.show()

kr2.connectTo("zbox")
let bytes2 = mkAddr(15)
let kt2 = KnxTelegramImplementation(bytes: bytes2)

let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
dispatch_after(time, dispatch_get_main_queue()) {
    kr2.submit(kt2)
    //kr2.show()
}





 