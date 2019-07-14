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
console.minLevel = .warning
SwiftyBeaver.addDestination(console)

class Handler: KnxDimmerResponseHandlerDelegate {

    func onOffResponse(sender: KnxGroupAddress, state: Bool) {

        print("ON: \(state)")
    }

    func dimLevelResponse(sender: KnxGroupAddress, level: Int) {

        print("DIM LEVEL: \(level)")
    }

    // No use for this...
    func subscriptionResponse(sender: AnyObject?, telegram: KnxTelegram) {
    }
}

let handler = Handler()

//KnxRouterInterface.routerIp = "gax58"
KnxRouterInterface.multicastGroup = "224.0.23.12"
KnxRouterInterface.knxSourceAddr = KnxDeviceAddress(fromString: "0.1.0")
KnxRouterInterface.connectionType = .udpMulticast

let onoffaddr = KnxGroupAddress(fromString: "1/0/8")

let lvlrspaddr = KnxGroupAddress(fromString: "3/5/21")

KnxGroupAddressRegistry.addTypeForGroupAddress(address: onoffaddr,
                                               type: KnxTelegramType.dpt1_xxx)

KnxGroupAddressRegistry.addTypeForGroupAddress(address: lvlrspaddr,
                                               type: KnxTelegramType.dpt5_001)

let dimmer =
    KnxDimmerControl(setOnOffAddress: onoffaddr,
                     setDimLevelAddress: KnxGroupAddress(fromString: "1/1/20"),
                     levelResponseAddress: lvlrspaddr, responseHandler:handler)

DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
    dimmer.dimLevel = 20
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
    dimmer.dimLevel = 75
}
