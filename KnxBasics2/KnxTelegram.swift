//
//  KnxTelegram.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public enum KnxTelegramType {
    
    case UNKNOWN
    case DPT1_xxx
    case DPT5_001
}

public protocol KnxTelegram {
    
    init()
    init(bytes:[UInt8], type:KnxTelegramType)
    
    var payload:[UInt8] { get }
    
    func getValueAsType(type:KnxTelegramType) throws -> Int
    
    func show()
}
