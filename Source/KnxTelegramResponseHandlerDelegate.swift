//
//  KnxTelegramResponseDelegate.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 27/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

/// Delegate protocol for KnxDimmerControl delegates.
public protocol KnxTelegramResponseHandlerDelegate {
    
    /**
     Handler for received telegrams.
     
     - parameter sender: The interface the telegram were received on.
     - parameter telegram: The received telegran.
     
     - returns: Nothing.
     */
    func subscriptionResponse(sender : AnyObject?, telegram:KnxTelegram)
}
