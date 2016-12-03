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

import Cocoa
import CocoaAsyncSocket
import SwiftyBeaver
import KnxBasics2

//: Set up logging with SwiftyBeaver
let console = ConsoleDestination()
console.asynchronously = false
SwiftyBeaver.addDestination(console)

/*:
 
 ---------
 
 */

KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


KnxGroupAddressRegistry.addTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"),
                                               type: KnxTelegramType.dpt1_xxx)

KnxGroupAddressRegistry.getTypeForGroupAddress(KnxGroupAddress(fromString:"1/2/3"))


