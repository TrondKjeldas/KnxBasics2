//
//  KnxDimmerControlImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation
import SwiftyBeaver

/// Class representing a dimmable light.
public class KnxDimmerControl : KnxTelegramResponseHandlerDelegate {
    
    // MARK: Public API:
    
    /**
     Initializes a new object.
     
     - parameter setOnOffAddress: The group address to use for turning light on and off.
     - parameter setDimLevelAddress: The group address to use for setting light level.
     - parameter levelResponseAddress: The group address to use for subscribing to light level changes.
     
     - returns: Nothing.
     */
    
    public init(setOnOffAddress:KnxGroupAddress,
                setDimLevelAddress:KnxGroupAddress,
                levelResponseAddress:KnxGroupAddress,
                responseHandler : KnxResponseHandlerDelegate) {
        
        onOffAddress = setOnOffAddress
        dimmerAddress = setDimLevelAddress
        levelRspAddress = levelResponseAddress
        
        self.lightOn  = false
        self._dimLevel = 0
        
        self.responseHandler = responseHandler
        
        onOffInterface = KnxRouterInterface(responseHandler: self)
        if let onOffInterface = onOffInterface {
            
            onOffInterface.connectTo("zbox")
            onOffInterface.submit(KnxTelegramFactory.createSubscriptionRequest(setOnOffAddress))
        }
        
        dimmerInterface = KnxRouterInterface(responseHandler: self)
        if let dimmerInterface = dimmerInterface {
            
            dimmerInterface.connectTo("zbox")
            dimmerInterface.submit(KnxTelegramFactory.createSubscriptionRequest(setDimLevelAddress))
        }
        
        levelRspInterface = KnxRouterInterface(responseHandler: self)
        if let levelRspInterface = levelRspInterface {
            
            levelRspInterface.connectTo("zbox")
            levelRspInterface.submit(KnxTelegramFactory.createSubscriptionRequest(levelResponseAddress))
        }
    }
    
    /// Read/write attribute holding the on/off state.
    public var lightOn:Bool {
        willSet(newValue) {
            if newValue != lightOn {
                var value = 0
                if newValue {
                    value = 1
                }
                log.verbose("lightOn soon: \(value)")
                try! onOffInterface!.submit(KnxTelegramFactory.createWriteRequest(KnxTelegramType.DPT1_xxx, value:value))
            }
        }
        didSet {
            log.verbose("lightOn now: \(lightOn)")
        }
    }
    
    /// Read/write attribute holding the light level.
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
     
     - returns: Nothing.
     */
    public func subscriptionResponse(sender : AnyObject?, telegram: KnxTelegram) {
        
        var type : KnxTelegramType
        
        let interface = sender as! KnxRouterInterface
        
        if interface == onOffInterface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(onOffAddress)
            do {
                let val = try telegram.getValueAsType(type)
                lightOn = Bool(val)
                responseHandler?.onOffResponse(lightOn)
            }
            catch KnxException.IllformedTelegramForType {
                
                log.error("Catched...")
            }
            catch {
                
                log.error("Catched...")
            }
        }
        else if interface == levelRspInterface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(levelRspAddress)
            do {
                _dimLevel = try telegram.getValueAsType(.DPT5_001)
                responseHandler?.dimLevelResponse(_dimLevel)
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
    private var dimmerAddress:KnxGroupAddress
    private var levelRspAddress:KnxGroupAddress
    
    private var onOffInterface:KnxRouterInterface?
    private var dimmerInterface:KnxRouterInterface?
    private var levelRspInterface:KnxRouterInterface?
    
    private var responseHandler:KnxResponseHandlerDelegate?
    
    private var _dimLevel : Int
    
    private let log = SwiftyBeaver.self
}