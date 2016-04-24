//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Cocoa

import CocoaAsyncSocket

import KnxBasics2

class Handler : KnxResponseHandlerDelegate {

    func subscriptionResponse(telegram: KnxTelegram) {
        
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

let dimmer =
    KnxDimmerControlImplementation(setOnOffAddress: KnxGroupAddressImplementation(fromString: "1/0/14"),
                                   setDimLevelAddress: KnxGroupAddressImplementation(fromString: "1/1/27"),
                                   levelResponseAddress: KnxGroupAddressImplementation(fromString: "3/5/26"), responseHandler:handler)







 