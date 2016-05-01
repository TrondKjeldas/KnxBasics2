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

class Handler : KnxDimmerResponseHandlerDelegate {
    
    
    func onOffResponse(on:Bool) {
        
        print("ON: \(on)")
    }
    
    func dimLevelResponse(level:Int) {
        
        print("DIM LEVEL: \(level)")
    }

    // No use for this...
    func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
    }
}

let handler = Handler()

KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/0/14"),
                                               type: KnxTelegramType.DPT1_xxx)

KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"3/5/26"),
                                               type: KnxTelegramType.DPT5_001)

let onoffaddr = KnxGroupAddress(fromString: "1/0/14")

let lvlrspaddr = KnxGroupAddress(fromString: "3/5/26")

let dimmer =
    KnxDimmerControl(setOnOffAddress: onoffaddr,
                     setDimLevelAddress: KnxGroupAddress(fromString: "1/1/27"),
                     levelResponseAddress: lvlrspaddr, responseHandler:handler)

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                dimmer.dimLevel = 20
}

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC))),
               dispatch_get_main_queue()) {
                dimmer.dimLevel = 75
}

