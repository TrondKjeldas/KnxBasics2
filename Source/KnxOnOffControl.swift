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
public class KnxOnOffControl : KnxTelegramResponseHandlerDelegate {
    
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
        
        onOffInterface = KnxRouterInterface(responseHandler: self)
        if let onOffInterface = onOffInterface {
            
            // TODO: Better error handling!
            try! onOffInterface.connect()
            onOffInterface.submit(KnxTelegramFactory.createSubscriptionRequest(setOnOffAddress))
        }
    }
    
    /// Read/write property holding the on/off state.
    public var lightOn:Bool {
        get {
            return _lightOn
        }
        set {
            if newValue != _lightOn {
                
                _lightOn = newValue
                
                log.verbose("lightOn soon: \(_lightOn)")
                try! onOffInterface!.submit(KnxTelegramFactory.createWriteRequest(KnxTelegramType.DPT1_xxx,
                    value:Int(_lightOn)))
            }
        }
    }
    
    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     */
    public func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var type : KnxTelegramType
        
        let interface = sender as! KnxRouterInterface
        
        if interface == onOffInterface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(onOffAddress)
            do {
                let val:Int = try telegram.getValueAsType(type)
                _lightOn = Bool(val)
                responseHandler?.onOffResponse(lightOn)
            }
            catch KnxException.IllformedTelegramForType {
                
                log.error("Catched...")
            }
            catch {
                
                log.error("Catched...")
            }
        }
        
        
        log.debug("HANDLING: \(telegram.payload)")
    }
    
    // MARK: Internal and private declarations
    
    private var onOffAddress:KnxGroupAddress
    
    private var onOffInterface:KnxRouterInterface?
    
    private var responseHandler:KnxOnOffResponseHandlerDelegate?
    
    private var _lightOn : Bool
    
    private let log = SwiftyBeaver.self
}
