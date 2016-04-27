//
//  KnxExceptions.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

/// Enumeration of the exceptions that can be raised from the classes in the framework.
public enum KnxException : ErrorType {
    
    /// Unknown value used for DPT.
    case UnknownTelegramType
    
    /// Not possible to decode telegram according to specified DPT.
    case IllformedTelegramForType
}
