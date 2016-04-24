//
//  KnxTelegramImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public class KnxTelegramImplementation : KnxTelegram {
  
    
    private var _bytes:[UInt8]?
    private var _len:Int
    private var _type:KnxTelegramType
    
    required public init() {
        
        _bytes = nil
        _len = 0
        _type = .UNKNOWN
    }

    required public init(bytes:[UInt8], type:KnxTelegramType = .UNKNOWN) {
    
        _bytes = bytes
        _len = bytes.count
        _type = type
    }
    
    public var payload:[UInt8] {
        get {
            return _bytes!
        }
    }
    
    public func getValueAsType(type:KnxTelegramType) throws -> Int {
        
        switch(type) {
            
        case .DPT001:
            return Int(_bytes![7] & 0x1)
        default:
            throw KnxException.UnknownTelegramType
        }
    }

     public func show() {
    
        print(_bytes)
    }
}