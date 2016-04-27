//: Playground - noun: a place where people can play

import Cocoa
import CocoaAsyncSocket
import KnxBasics2


KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"),
                                               type: KnxTelegramType.DPT1_xxx)

KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


