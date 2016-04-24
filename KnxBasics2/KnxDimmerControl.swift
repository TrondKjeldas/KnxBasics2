//
//  KnxDimmerControl.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 21/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation


protocol KnxDimmerControl {
    
    init(setOnOffAddress:KnxGroupAddress, setDimLevelAddress:KnxGroupAddress, setLevelResponseAddress:KnxGroupAddress);
    
    init(setOnOffAddress:KnxGroupAddress, setDimLevelAddress:KnxGroupAddress, setLevelResponseAddress:KnxGroupAddress,
         onOffResponseHandler:(), levelResponseHandler:());
    
    var lightOn:Bool { get set }
    
    var dimLevel:Int { get set }
    
}
