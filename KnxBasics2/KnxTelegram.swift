//
//  KnxTelegram.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation


public protocol KnxTelegram {
    

    init()
    init(bytes:[UInt8])
    
    var payload:[UInt8] { get }
    
    func show()
}
