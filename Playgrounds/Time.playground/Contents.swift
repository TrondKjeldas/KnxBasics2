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
console.asynchronously = false
console.minLevel = .info
SwiftyBeaver.addDestination(console)

class Handler: KnxTelegramResponseHandlerDelegate {

    func subscriptionResponse(sender: AnyObject?, telegram: KnxTelegram) {

        do {
            let time: String = try telegram.getValueAsType(type: .dpt10_001)
            print("Time: \(time)")
        } catch {
            print("Catched...")
        }
    }
}

let handler = Handler()

KnxGroupAddressRegistry.addTypeForGroupAddress(address: KnxGroupAddress(fromString:"3/6/0"),
                                               type: KnxTelegramType.dpt10_001)

KnxRouterInterface.routerIp = "gax58"
KnxRouterInterface.multicastGroup = "224.0.23.12"
KnxRouterInterface.knxSourceAddr = KnxDeviceAddress(fromString: "0.1.0")
KnxRouterInterface.connectionType = .udpMulticast

let kr = KnxRouterInterface.getKnxRouterInstance()

try! kr?.connect()
kr?.subscribeFor(address: KnxGroupAddress(fromString: "3/6/0"),
                 responseHandler: handler)
