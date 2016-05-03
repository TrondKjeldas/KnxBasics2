//
//  KnxDimmerControl.swift
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

/// Class representing a dimmable light.
public class KnxDimmerControl : KnxOnOffControl {
    
    // MARK: Public API:
    
    /**
     Initializes a new object.
     
     - parameter setOnOffAddress: The group address to use for turning light on and off.
     - parameter setDimLevelAddress: The group address to use for setting light level.
     - parameter levelResponseAddress: The group address to use for subscribing to light level changes.
     */
    
    public init(setOnOffAddress:KnxGroupAddress,
                setDimLevelAddress:KnxGroupAddress,
                levelResponseAddress:KnxGroupAddress,
                responseHandler : KnxDimmerResponseHandlerDelegate) {
        
        dimmerAddress = setDimLevelAddress
        levelRspAddress = levelResponseAddress
        
        self._dimLevel = 0
        
        self.dimmerResponseHandler = responseHandler

        // Initialize super for on/off functionality
        super.init(setOnOffAddress: setOnOffAddress, responseHandler: responseHandler)

        dimmerInterface = KnxRouterInterface(responseHandler: self)
        if let dimmerInterface = dimmerInterface {
            
            // TODO: Better error handling!
            try! dimmerInterface.connect()
            dimmerInterface.submit(KnxTelegramFactory.createSubscriptionRequest(setDimLevelAddress))
        }
        
        levelRspInterface = KnxRouterInterface(responseHandler: self)
        if let levelRspInterface = levelRspInterface {
            
            // TODO: Better error handling!
            try! levelRspInterface.connect()
            levelRspInterface.submit(KnxTelegramFactory.createSubscriptionRequest(levelResponseAddress))
            readLevel()
        }
    }
    
    /**
     Trigger reading of dimmer level.
     */
    public func readLevel() {

        levelRspInterface?.submit(KnxTelegramFactory.createReadRequest(levelRspAddress))
    }
    
    /// Read/write property holding the light level.
    public var dimLevel:Int{
        get {
            return _dimLevel
        }
        set {
            if newValue != _dimLevel {
                log.verbose("dimLevel soon: \(newValue)")
                try! dimmerInterface!.submit(KnxTelegramFactory.createWriteRequest(KnxTelegramType.DPT5_001, value:newValue))
            }
        }
    }


    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     */
    public override func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var type : KnxTelegramType
        
        let interface = sender as! KnxRouterInterface
        
        if interface == levelRspInterface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(levelRspAddress)
            do {
                _dimLevel = try telegram.getValueAsType(type)
                dimmerResponseHandler?.dimLevelResponse(_dimLevel)
            }
            catch KnxException.IllformedTelegramForType {
                
                log.error("Catched...")
            }
            catch {
                
                log.error("Catched...")
            }
        } else {
            // Also give super a shot...
            super.subscriptionResponse(sender, telegram: telegram)
        }
        
        log.debug("HANDLING: \(telegram.payload)")
    }
    
    // MARK: Internal and private declarations
    
    private var dimmerAddress:KnxGroupAddress
    private var levelRspAddress:KnxGroupAddress
    
    private var dimmerInterface:KnxRouterInterface?
    private var levelRspInterface:KnxRouterInterface?
    
    private var dimmerResponseHandler:KnxDimmerResponseHandlerDelegate?
    
    private var _dimLevel : Int
    
    private let log = SwiftyBeaver.self
}
