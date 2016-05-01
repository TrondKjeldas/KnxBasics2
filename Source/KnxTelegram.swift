//
//  KnxTelegram.swift
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

/// Identifies the different KNX DPTs.
public enum KnxTelegramType {
    
    /// Unknown/unspecified DPT.
    case UNKNOWN
    
    /// A generic 1-bit value in the range of DPT 1.001 - 1.022.
    case DPT1_xxx
    
    /// Scaling value, range 0-100%.
    case DPT5_001
    
    /// Temperature, in degree celsius
    case DPT9_001
}

/// Class representing a KNX telegram.
public class KnxTelegram {
    
    // MARK: Public API
    
    /// Default initializer.
    public init() {
        
        _bytes = nil
        _len = 0
        _type = .UNKNOWN
    }
    
    /**
     Intializes a telegram instance with the given data and type.
     
     - parameter bytes: The payload to initialize the telegram with.
     - parameter type: The DPT type to set for the telegram.
     
     - returns: Nothing.
     */
    public init(bytes:[UInt8], type:KnxTelegramType = .UNKNOWN) {
        
        _bytes = bytes
        _len = bytes.count
        _type = type
    }
    
    /**
     Returns the data value in the telegram as a specific DPT.
     
     - parameter type: DPT type to decode the telegram according to.
     
     - returns: The decoded value as an integer.
     */
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

    /**
     Returns the data value in the telegram as a specific DPT.
     
     - parameter type: DPT type to decode the telegram according to.
     
     - returns: The decoded value as a float.
     */
    public func getValueAsType(type:KnxTelegramType) throws -> Double {
        
        switch(type) {
            
        case .DPT9_001:
            
            if(_bytes!.count != 10) {
                throw KnxException.IllformedTelegramForType
            }
            
            //FloatValue = (0,01*M)*2(E)
            //E = [0 ... 15]
            //M = [-2 048 ... 2 047], two’s complement notation
            //For all Datapoint Types 9.xxx, the encoded value 7FFFh shall always be used to denote invalid data.
            
            let val:UInt16 = (UInt16(_bytes![9] & 0xff) | (UInt16(_bytes![8] & 0xff)<<8))
            let sign = ((val & 0x8000) >> 15)
            let exp = (val & 0x7800) >> 11
            
            var mantissa : Int32 = Int32(val & 0x7FF)
            
            if sign == 1 {
                
                mantissa = -1 - mantissa
            }
            
            let twoExp = Int32(1 << exp)
            
            mantissa *= twoExp
            
            let floatVal = Double(mantissa) * 0.01
            
            return floatVal
            
            
        default:
            throw KnxException.UnknownTelegramType
        }
    }
    
    // MARK: Internal and private declarations
    
    private var _bytes:[UInt8]?
    private var _len:Int
    private var _type:KnxTelegramType
    
    internal var payload:[UInt8] {
        get {
            return _bytes!
        }
    }
    
}
