//
//  KnxTelegramImplementation.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

//import KnxTelegram

class KnxTelegramImplementation : KnxTelegram {
  
    private var _s:String
    
    internal required init(s:String) {
    
        _s = s
    }
    
    internal func show() -> Int {
    
        print(_s)
    
        return 0
    }
}