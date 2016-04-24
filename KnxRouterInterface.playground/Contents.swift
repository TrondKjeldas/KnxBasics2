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
            val = try telegram.getValueAsType(.DPT001)
        }
        catch {
            print("Catched...")
        }
        print("HANDLING: \(telegram.payload), \(val)")
    }
}

let handler = Handler()
let factory = KnxTelegramFactoryImplementation()
let kr = KnxRouterInterfaceImplementation(responseHandler: handler)
let kr2 = KnxRouterInterfaceImplementation(responseHandler: handler)


kr.connectTo("zbox")
kr.submit(factory.createSubscriptionRequest(KnxGroupAddressImplementation(fromString: "1/0/15")))

kr2.connectTo("zbox")
kr2.submit(factory.createSubscriptionRequest(KnxGroupAddressImplementation(fromString: "1/0/16")))





 