//
//  KnxResponseHandlerDelegate.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 23/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

/// Delegate protocol for KnxDimmerControl delegates.
public protocol KnxResponseHandlerDelegate {
    
    /**
     Handler for changes in on/off state.
     
     - parameter on: True if light on, false if light off.
     
     - returns: Noting.
     */
    func onOffResponse(on:Bool)
    
    /**
     Handler for changes in dimmer level.
     
     - parameter level: The new dimmer level.
     
     - returns: Nothing.
     */
    func dimLevelResponse(level:Int)
}
