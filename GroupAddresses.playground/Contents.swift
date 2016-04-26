//: Playground - noun: a place where people can play

import Cocoa
import CocoaAsyncSocket
import KnxBasics2


KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddressImplementation(fromString:"1/2/3"))


KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddressImplementation(fromString:"1/2/3"),
                                               type: KnxTelegramType.DPT1_xxx)

KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddressImplementation(fromString:"1/2/3"))


