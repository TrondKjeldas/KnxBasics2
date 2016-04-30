//: Playground - noun: a place where people can play

import Cocoa
import CocoaAsyncSocket
import SwiftyBeaver
import KnxBasics2


let console = ConsoleDestination()
console.detailOutput = false
console.asynchronously = false
SwiftyBeaver.addDestination(console)



KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"),
                                               type: KnxTelegramType.DPT1_xxx)

KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


