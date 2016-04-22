//
//  KnxTelegramImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

//import KnxTelegram

public class KnxTelegramImplementation : KnxTelegram {
  
  /*
    -(UInt8*)bytes;
    -(size_t)bufsize;
    
    -(size_t)length;
    -(UInt16)type;
    -(UInt8*)payload;
    
    -(void)log;
    */
    
    private var _bytes:[UInt8]?
    private var _len:Int
    
    required public init() {
        
        _bytes = nil
        _len = 0
    }

    required public init(bytes:[UInt8]) {
    
        _bytes = bytes
        _len = bytes.count
    }
    
    public var payload:[UInt8] {
        get {
            return _bytes!
        }
    }
     public func show() {
    
        print(_bytes)
    }
}