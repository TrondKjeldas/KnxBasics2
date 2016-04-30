//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket
import SwiftyBeaver
import KnxBasics2

let console = ConsoleDestination()
console.detailOutput = false
console.asynchronously = false
console.minLevel = .Warning
SwiftyBeaver.addDestination(console)

class Handler : KnxResponseHandlerDelegate {

    func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var val = -1
        do {
            val = try telegram.getValueAsType(.DPT5_001)
        }
        catch {
            print("Catched...")
        }
       // print("HANDLING: \(telegram.payload), \(val)")
    }
    
    func onOffResponse(on:Bool) {
        
        print("ON: \(on)")
    }
    
    func dimLevelResponse(level:Int) {
        
        print("DIM LEVEL: \(level)")
    }

}

let handler = Handler()


KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/0/14"),
                                               type: KnxTelegramType.DPT1_xxx)

KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"3/5/26"),
                                               type: KnxTelegramType.DPT5_001)


/*

let kr = KnxRouterInterface(responseHandler: handler)
let kr2 = KnxRouterInterface(responseHandler: handler)

kr.connectTo("zbox")
kr.submit(KnxTelegramFactory.createSubscriptionRequest(KnxGroupAddress(fromString: "3/5/26")))

kr2.connectTo("zbox")
kr2.submit(KnxTelegramFactory.createSubscriptionRequest(KnxGroupAddress(fromString: "1/0/14")))

*/

let onoffaddr = KnxGroupAddress(fromString: "1/0/14")
onoffaddr.addressAsUInt16
let s = String(format: "0x%x", onoffaddr.addressAsUInt16)
print("oa: \(s)")

let lvlrspaddr = KnxGroupAddress(fromString: "3/5/26")
lvlrspaddr.addressAsUInt16

let dimmer =
    KnxDimmerControl(setOnOffAddress: onoffaddr,
                                   setDimLevelAddress: KnxGroupAddress(fromString: "1/1/27"),
                                   levelResponseAddress: lvlrspaddr, responseHandler:handler)

dimmer.lightOn = true


dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                dimmer.dimLevel = 1
                
}


dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                dimmer.dimLevel = 75
}


 
