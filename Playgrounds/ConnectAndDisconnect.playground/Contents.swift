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
import SwiftyBeaver
import KnxBasics2

let console = ConsoleDestination()
console.minLevel = .info
console.asynchronously = false
SwiftyBeaver.addDestination(console)

class Handler : KnxTelegramResponseHandlerDelegate {
    
    func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var val = -1
        do {
            val = try telegram.getValueAsType(type: .dpt5_001)
            print("Got response with value: \(val)")
        }
        catch {
            do {
                val = try telegram.getValueAsType(type: .dpt1_xxx)
                print("Got response with value: \(val)")
            }
            catch {
                print("Catched...")
            }
        }
    }
}

let handler = Handler()

KnxGroupAddressRegistry.addTypeForGroupAddress(address: KnxGroupAddress(fromString:"3/5/26"),
                                               type: KnxTelegramType.dpt5_001)

KnxRouterInterface.routerIp = "gax58"
KnxRouterInterface.connectionType = .tcpDirect

let kr = KnxRouterInterface.getKnxRouterInstance()

try! kr?.connect()
kr?.subscribeFor(address: KnxGroupAddress(fromString: "3/5/26"), responseHandler: handler)


DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
    kr?.disconnect()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
    try! kr?.connect()
    kr?.subscribeFor(address: KnxGroupAddress(fromString: "3/5/26"), responseHandler: handler)
}
