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
            
        case .DPT1_xxx:

            if(_bytes!.count != 8) {
                throw KnxException.IllformedTelegramForType
            }
            return Int(_bytes![7] & 0x1)
            
        case .DPT5_001:
            
            if(_bytes!.count != 9) {
                throw KnxException.IllformedTelegramForType
            }
            
            let dimVal = Int(_bytes![8] & 0xff)
            
            return (dimVal * 100) / 255

        default:
            throw KnxException.UnknownTelegramType
        }
    }

     public func show() {
    
        print(_bytes)
    }
}