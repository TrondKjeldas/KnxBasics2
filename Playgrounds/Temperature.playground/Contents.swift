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

//: Set up logging with SwiftyBeaver
let console = ConsoleDestination()
console.asynchronously = false
SwiftyBeaver.addDestination(console)


class Handler : KnxTemperatureResponseHandlerDelegate {
    
    func temperatureResponse(_ level: Double) {

        print("Temperature now: \(level)")
    }
}

KnxRouterInterface.routerIp = "zbox"

KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"3/2/0"),
                                               type: KnxTelegramType.dpt9_001)

let sub = KnxTemperatureControl(subscriptionAddress: KnxGroupAddress(fromString: "3/2/0"),
                                responseHandler: Handler())
