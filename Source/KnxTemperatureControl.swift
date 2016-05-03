//
//  KnxTemperatureControl.swift
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

/// Class allowing subscription on temperature.
public class KnxTemperatureControl : KnxTelegramResponseHandlerDelegate {
    
    // MARK: Public API:
    
    /**
     Initializes a new object.
     
     - parameter setOnOffAddress: The group address to use for turning light on and off.
     
     - returns: Nothing.
     */
    
    public init(subscriptionAddress:KnxGroupAddress,
                responseHandler : KnxTemperatureResponseHandlerDelegate) {
        
        self.subscriptionAddress = subscriptionAddress
        
        self.responseHandler = responseHandler
        
        self._temperature = 0.0
        
        interface = KnxRouterInterface(responseHandler: self)
        if let interface = interface {
            
            // TODO: Better error handling!
            try! interface.connect()
            interface.submit(KnxTelegramFactory.createSubscriptionRequest(subscriptionAddress))
        }
    }
    
    /// Read-only attribute holding the last received.
    public var temperature:Double {
        get {
            return _temperature
        }
    }
    
    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     
     - returns: Nothing.
     */
    public func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var type : KnxTelegramType
        
        let interface = sender as! KnxRouterInterface
        
        if interface == self.interface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(subscriptionAddress)
            do {
                _temperature = try telegram.getValueAsType(type)
                responseHandler?.temperatureResponse(_temperature)
            }
            catch KnxException.IllformedTelegramForType {
                
                log.error("Catched...")
            }
            catch {
                // TODO: Improve error handling.
                log.error("Catched...")
            }
        }
        
        
        log.debug("HANDLING: \(telegram.payload)")
    }
    
    // MARK: Internal and private declarations
    
    private var subscriptionAddress:KnxGroupAddress
    
    private var interface:KnxRouterInterface?
    
    private var responseHandler:KnxTemperatureResponseHandlerDelegate?
    
    private var _temperature : Double
    
    private let log = SwiftyBeaver.self
}
