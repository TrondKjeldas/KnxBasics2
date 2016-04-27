//
//  KnxExceptions.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 24/04/16.
//  Copyright © 2016 Trond Kjeldås. All rights reserved.
//

import Foundation

public enum KnxException : ErrorType {
    
    case UnknownTelegramType
    case IllformedTelegramForType
}
