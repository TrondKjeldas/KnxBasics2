//
//  KnxDimmerControlImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxDimmerControlImplementation : KnxDimmerControl, KnxResponseHandlerDelegate {
    
    private var onOffAddress:KnxGroupAddress
    private var dimmerAddress:KnxGroupAddress
    private var levelRspAddress:KnxGroupAddress
    
    private var onOffInterface:KnxRouterInterfaceImplementation?
    private var dimmerInterface:KnxRouterInterfaceImplementation?
    private var levelRspInterface:KnxRouterInterfaceImplementation?
    
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
        
        onOffInterface = KnxRouterInterfaceImplementation(responseHandler: self)
        if let onOffInterface = onOffInterface {
            
            onOffInterface.connectTo("zbox")
            onOffInterface.submit(KnxTelegramFactoryImplementation.createSubscriptionRequest(setOnOffAddress))
        }

        dimmerInterface = KnxRouterInterfaceImplementation(responseHandler: self)
        if let dimmerInterface = dimmerInterface {
            
            dimmerInterface.connectTo("zbox")
        }

        levelRspInterface = KnxRouterInterfaceImplementation(responseHandler: self)
        if let levelRspInterface = levelRspInterface {
            
            levelRspInterface.connectTo("zbox")
            levelRspInterface.submit(KnxTelegramFactoryImplementation.createSubscriptionRequest(levelResponseAddress))
        }
    }
    
    public var lightOn:Bool
    
    public var dimLevel:Int
    
    public func subscriptionResponse(telegram: KnxTelegram) {
        var val = -1
        do {
            val = try telegram.getValueAsType(.DPT1_xxx)
            lightOn = Bool(val)
            responseHandler?.onOffResponse(lightOn)
            
        }
        catch KnxException.IllformedTelegramForType {
            
            do {
                dimLevel = try telegram.getValueAsType(.DPT5_001)
                responseHandler?.dimLevelResponse(dimLevel)
            }
            catch  {
                print("Catched...")
            }
        }
        catch  {
            print("Catched...")
        }

        print("HANDLING: \(telegram.payload), \(val)")
    }
    
    public func onOffResponse(on:Bool) {
    }
    
    public func dimLevelResponse(level:Int) {
    }
    
}

