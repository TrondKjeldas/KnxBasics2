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
open class KnxDimmerControl : KnxOnOffControl {
    
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

        dimmerInterface = KnxRouterInterface.getKnxRouterInstance()
        if let dimmerInterface = dimmerInterface {
            
            // TODO: Better error handling!
            try! dimmerInterface.connect()
            dimmerInterface.subscribeFor(address: setDimLevelAddress,
                                         responseHandler: self)
        }
        
        levelRspInterface = KnxRouterInterface.getKnxRouterInstance()
        if let levelRspInterface = levelRspInterface {
            
            // TODO: Better error handling!
            try! levelRspInterface.connect()
            levelRspInterface.subscribeFor(address: levelRspAddress,
                                           responseHandler: self)
            readLevel()
        }
    }
    
    /**
     Trigger reading of dimmer level.
     */
    open func readLevel() {

        levelRspInterface?.sendReadRequest(to: levelRspAddress)
    }
    
    /// Read/write property holding the light level.
    open var dimLevel:Int{
        get {
            return _dimLevel
        }
        set {
            if newValue != _dimLevel {
                log.verbose("dimLevel soon: \(newValue)")
                dimmerInterface?.sendWriteRequest(to: dimmerAddress, type: .dpt5_001, value: newValue)
            }
        }
    }


    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     */
    open override func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        let type : KnxTelegramType
        
        switch KnxRouterInterface.connectionType {
        case .tcpDirect:

            let interface = sender as! KnxRouterInterface

            if interface == levelRspInterface {
                type = KnxGroupAddressRegistry.getTypeForGroupAddress(address: levelRspAddress)
                do {
                    _dimLevel = try telegram.getValueAsType(type: type)
                    dimmerResponseHandler?.dimLevelResponse(sender: levelRspAddress,
                                                            level: _dimLevel)
                }
                catch KnxException.illformedTelegramForType {

                    log.error("Illegal telegram type...")
                }
                catch let error as NSError {

                    log.error("Error: \(error)")
                }
            } else {
                // Also give super a shot...
                super.subscriptionResponse(sender:sender, telegram: telegram)
            }

        case .udpMulticast:

            let srcAddress = telegram.getGroupAddress()

            if srcAddress == levelRspAddress {
                type = KnxGroupAddressRegistry.getTypeForGroupAddress(address: levelRspAddress)
                do {
                    _dimLevel = try telegram.getValueAsType(type: type)
                    dimmerResponseHandler?.dimLevelResponse(sender: levelRspAddress,
                                                            level: _dimLevel)
                }
                catch KnxException.illformedTelegramForType {

                    log.error("Illegal telegram type...")
                }
                catch let error as NSError {
                    
                    log.error("Error: \(error)")
                }
            } else {
                // Also give super a shot...
                super.subscriptionResponse(sender:sender, telegram: telegram)
            }

        default:
            log.error("Connection type not set")
        }


        log.debug("HANDLING: \(telegram.payload)")
    }
    
    // MARK: Internal and private declarations
    
    fileprivate var dimmerAddress:KnxGroupAddress
    fileprivate var levelRspAddress:KnxGroupAddress
    
    fileprivate var dimmerInterface:KnxRouterInterface?
    fileprivate var levelRspInterface:KnxRouterInterface?
    
    fileprivate var dimmerResponseHandler:KnxDimmerResponseHandlerDelegate?
    
    fileprivate var _dimLevel : Int
    
    fileprivate let log = SwiftyBeaver.self
}
