//
//  KnxDimmerControlImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxDimmerControl : KnxResponseHandlerDelegate {
    
    private var onOffAddress:KnxGroupAddress
    private var dimmerAddress:KnxGroupAddress
    private var levelRspAddress:KnxGroupAddress
    
    private var onOffInterface:KnxRouterInterface?
    private var dimmerInterface:KnxRouterInterface?
    private var levelRspInterface:KnxRouterInterface?
    
    private var responseHandler:KnxResponseHandlerDelegate?
        
    public required init(setOnOffAddress:KnxGroupAddress,
                         setDimLevelAddress:KnxGroupAddress,
                         levelResponseAddress:KnxGroupAddress,
                         responseHandler : KnxResponseHandlerDelegate) {

        onOffAddress = setOnOffAddress
        dimmerAddress = setDimLevelAddress
        levelRspAddress = levelResponseAddress
        
        self.lightOn  = false
        self.dimLevel = 0
        
        self.responseHandler = responseHandler
        
        onOffInterface = KnxRouterInterface(responseHandler: self)
        if let onOffInterface = onOffInterface {
            
            onOffInterface.connectTo("zbox")
            onOffInterface.submit(KnxTelegramFactory.createSubscriptionRequest(setOnOffAddress))
        }

        dimmerInterface = KnxRouterInterface(responseHandler: self)
        if let dimmerInterface = dimmerInterface {
            
            dimmerInterface.connectTo("zbox")
        }

        levelRspInterface = KnxRouterInterface(responseHandler: self)
        if let levelRspInterface = levelRspInterface {
            
            levelRspInterface.connectTo("zbox")
            levelRspInterface.submit(KnxTelegramFactory.createSubscriptionRequest(levelResponseAddress))
        }
    }
    
    public var lightOn:Bool {
        willSet(newValue) {
            if newValue != lightOn {
                var value = 0
                if newValue {
                    value = 1
                }
                print("lightOn soon: \(value)")
                onOffInterface!.submit(KnxTelegramFactory.createWriteRequest(KnxTelegramType.DPT1_xxx, value:value))
            }
        }
        didSet {
            print("lightOn now: \(lightOn)")
        }
    }
    
    public var dimLevel:Int
    
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
                
                print("Catched...")
            }
            catch {
                
                print("Catched...")
            }
        }
        else if interface == levelRspInterface {
             type = KnxGroupAddressRegistry.getTypeForGroupAddress(levelRspAddress)
            do {
                dimLevel = try telegram.getValueAsType(.DPT5_001)
                responseHandler?.dimLevelResponse(dimLevel)
            }
            catch KnxException.IllformedTelegramForType {
                
                print("Catched...")
            }
            catch {
                
                print("Catched...")
            }
        }
    

        print("HANDLING: \(telegram.payload)")
    }
    
    public func onOffResponse(on:Bool) {
    }
    
    public func dimLevelResponse(level:Int) {
    }
    
}

