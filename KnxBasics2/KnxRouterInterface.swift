//
//  KnxRouterInterface.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public protocol KnxRouterInterface {
    
    init()
    
    func connectTo(ipAddress:String, onPort:UInt16)
    
    func submit(telegram:KnxTelegram)
    
    func show()
}