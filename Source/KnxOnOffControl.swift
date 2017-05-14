//
//  KnxOnOffControl.swift
//  KnxBasics2
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

import Foundation
import SwiftyBeaver


/// Class representing a light switch.
open class KnxOnOffControl : KnxTelegramResponseHandlerDelegate {
    
    // MARK: Public API:
    
    /**
     Initializes a new object.
     
     - parameter setOnOffAddress: The group address to use for turning light on and off.
     */
    
    public init(setOnOffAddress:KnxGroupAddress,
                responseHandler : KnxOnOffResponseHandlerDelegate) {
        
        onOffAddress = setOnOffAddress
        
        self._lightOn  = false
        
        self.responseHandler = responseHandler
        
        onOffInterface = KnxRouterInterface.getKnxRouterInstance()
        
        if let onOffInterface = onOffInterface {

            // TODO: Better error handling!
            try! onOffInterface.connect()

            onOffInterface.subscribeFor(address: setOnOffAddress,
                                        responseHandler: self)
        }
    }
    
    /// Read/write property holding the on/off state.
    open var lightOn:Bool {
        get {
            return _lightOn
        }
        set {
            if newValue != _lightOn {
                
                _lightOn = newValue
                
                log.verbose("lightOn soon: \(_lightOn)")
                onOffInterface?.sendWriteRequest(to: onOffAddress, type: .dpt10_001, value: _lightOn ? 1 : 0)
            }
        }
    }
    
    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     */
    open func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        let type : KnxTelegramType

        switch KnxRouterInterface.connectionType {
        case .tcpDirect:

            let interface = sender as! KnxRouterInterface

            if interface == onOffInterface {
                type = KnxGroupAddressRegistry.getTypeForGroupAddress(address: onOffAddress)
                do {
                    let val:Int = try telegram.getValueAsType(type: type)
                    _lightOn = Bool(NSNumber(value:val))
                    responseHandler?.onOffResponse(sender: onOffAddress,
                                                   state: _lightOn)
                }
                catch KnxException.illformedTelegramForType {

                    log.error("Illegal telegram type...")
                }
                catch let error as NSError {

                    log.error("Error: \(error)")
                }
            }

        case .udpMulticast:

            let srcAddress = telegram.getGroupAddress()

            if srcAddress == onOffAddress {

                type = KnxGroupAddressRegistry.getTypeForGroupAddress(address: onOffAddress)
                do {
                    let val:Int = try telegram.getValueAsType(type: type)
                    _lightOn = Bool(NSNumber(value:val))
                    responseHandler?.onOffResponse(sender: onOffAddress,
                                                   state: _lightOn)
                }
                catch KnxException.illformedTelegramForType {

                    log.error("Illegal telegram type...")
                }
                catch let error as NSError {

                    log.error("Error: \(error)")
                }
            }

        default:
            log.error("Connection type not set")
        }
        
        log.debug("HANDLING: \(telegram.payload)")
    }
    
    // MARK: Internal and private declarations
    
    fileprivate var onOffAddress:KnxGroupAddress
    
    fileprivate var onOffInterface:KnxRouterInterface?
    
    fileprivate var responseHandler:KnxOnOffResponseHandlerDelegate?
    
    fileprivate var _lightOn : Bool
    
    fileprivate let log = SwiftyBeaver.self
}
