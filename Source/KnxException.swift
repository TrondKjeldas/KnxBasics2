//
//  KnxExceptions.swift
//  KnxBasics2
//
//  The KnxBasics2 framework provides basic interworking with a KNX installation.
//  Copyright © 2016 Trond Kjeldås (trond@kjeldas.no).
//
//  This library is free software; you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License Version 2.1
//  as published by the Free Software Foundation.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this library; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

import Foundation

/// Enumeration of the exceptions that can be raised from the classes in the framework.
public enum KnxException : ErrorType {
    
    /// A connection to the KNX router could not be initiated
    case UnableToConnectToRouter
    
    /// Unknown value used for DPT.
    case UnknownTelegramType
    
    /// Not possible to decode telegram according to specified DPT.
    case IllformedTelegramForType
}
