//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket

import KnxBasics2

class Handler : KnxResponseHandlerDelegate {

    func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var val = -1
        do {
            val = try telegram.getValueAsType(.DPT5_001)
        }
        catch {
            print("Catched...")
        }
        print("HANDLING: \(telegram.payload), \(val)")
    }
    
    func onOffResponse(on:Bool) {
        
        print("ON: \(on)")
    }
    
    func dimLevelResponse(level:Int) {
        
        print("DIM LEVEL: \(level)")
    }

}

let handler = Handler()

/*

let kr = KnxRouterInterfaceImplementation(responseHandler: handler)
let kr2 = KnxRouterInterfaceImplementation(responseHandler: handler)

kr.connectTo("zbox")
kr.submit(KnxTelegramFactoryImplementation.createSubscriptionRequest(KnxGroupAddressImplementation(fromString: "3/5/26")))

kr2.connectTo("zbox")
kr2.submit(KnxTelegramFactoryImplementation.createSubscriptionRequest(KnxGroupAddressImplementation(fromString: "1/0/14")))

*/

let onoffaddr = KnxGroupAddressImplementation(fromString: "1/0/14")
onoffaddr.addressAsUInt16
let s = String(format: "0x%x", onoffaddr.addressAsUInt16)
print("oa: \(s)")

let lvlrspaddr = KnxGroupAddressImplementation(fromString: "3/5/26")
lvlrspaddr.addressAsUInt16

let dimmer =
    KnxDimmerControlImplementation(setOnOffAddress: onoffaddr,
                                   setDimLevelAddress: KnxGroupAddressImplementation(fromString: "1/1/27"),
                                   levelResponseAddress: lvlrspaddr, responseHandler:handler)

//dimmer.lightOn = true


dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                //dimmer.lightOn = !dimmer.lightOn
}


dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                //dimmer.lightOn = !dimmer.lightOn
}


 