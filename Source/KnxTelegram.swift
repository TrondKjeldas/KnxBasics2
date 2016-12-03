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
    case unknown
    
    /// A generic 1-bit value in the range of DPT 1.001 - 1.022.
    /// DPT1.001 - On/off
    /// DPT1.002 - True/false
    /// DPT1.003 - Enable/disable
    /// DPT1.005 - Alarm/no alarm
    /// DPT1.009 - Close/open
    /// DPT1.015 - Reset/no action
    case dpt1_xxx

    /// Dimming control
    case dpt3_007
    
    /// Scaled value, range 0-100%.
    case dpt5_001
    
    /// Temperature, in degree celsius
    case dpt9_001

    /// Brightness
    case dpt9_004
    
    /// Wind
    case dpt9_005
    
    /// Time of day
    case dpt10_001
    
    /// Scene number
    case dpt17_001
    
    /// HVAC mode
    case dpt20_102
    
    /// Combined info, on/off
    case dpt27_001
}

/// Class representing a KNX telegram.
open class KnxTelegram {
    
    // MARK: Public API
    
    /// Default initializer.
    public init() {
        
        _bytes = nil
        _len = 0
        _type = .unknown
    }
    
    /**
     Intializes a telegram instance with the given data and type.
     
     - parameter bytes: The payload to initialize the telegram with.
     - parameter type: The DPT type to set for the telegram.
     */
    public init(bytes:[UInt8], type:KnxTelegramType = .unknown) {
        
        _bytes = bytes
        _len = bytes.count
        _type = type
    }
    
    /**
     Returns the data value in the telegram as a specific DPT.
     
     - parameter type: DPT type to decode the telegram according to.
     
     - returns: The decoded value as an integer.
     - throws: IllformedTelegramForType, UnknownTelegramType
     */
    open func getValueAsType(_ type:KnxTelegramType) throws -> Int {
        
        switch(type) {
            
        case .dpt1_xxx:
            
            if(_bytes!.count != 8) {
                throw KnxException.illformedTelegramForType
            }
            return Int(_bytes![7] & 0x1)

        case .dpt3_007:
            
            if(_bytes!.count != 8) {
                throw KnxException.illformedTelegramForType
            }
            
            var returnValue : Int = 0
            
            let inc = (_bytes![7] & 0x08) == 0x08
            let stepcode = Int(_bytes![7] & 0x07)
            
            if stepcode == 0 {
            
                // Stop!
                returnValue = 0
                
            } else {
                
                // Go!
                let steps = 1 << (stepcode-1)
                
                if inc  {
                    returnValue = steps
                } else {
                    returnValue = -steps
                }
            }
            
            return returnValue

            
        case .dpt5_001:
            
            if(_bytes!.count != 9) {
                throw KnxException.illformedTelegramForType
            }
            
            let dimVal = Int(_bytes![8] & 0xff)
            
            return (dimVal * 100) / 255
            
        default:
            throw KnxException.unknownTelegramType
        }
    }

    /**
     Returns the data value in the telegram as a specific DPT.
     
     - parameter type: DPT type to decode the telegram according to.
     
     - returns: The decoded value as a float.
     - throws: IllformedTelegramForType, UnknownTelegramType
     */
    open func getValueAsType(_ type:KnxTelegramType) throws -> Double {
        
        switch(type) {
            
        case .dpt9_001: fallthrough
        case .dpt9_004: fallthrough
        case .dpt9_005:
            
            if(_bytes!.count != 10) {
                throw KnxException.illformedTelegramForType
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
      
                mantissa = 2048 - mantissa
                mantissa = -mantissa
            }
            
            let twoExp = Int32(1 << exp)
            
            mantissa *= twoExp
            
            let floatVal = Double(mantissa) * 0.01
            
            return floatVal
            
            
        default:
            throw KnxException.unknownTelegramType
        }
    }
    
    /**
     Returns the data value in the telegram as a specific DPT.
     
     - parameter type: DPT type to decode the telegram according to.
     
     - returns: The decoded value as a string.
     - throws: IllformedTelegramForType, UnknownTelegramType     
     */
    open func getValueAsType(_ type:KnxTelegramType) throws -> String {
        
        switch(type) {
            
        case .dpt10_001:
            
            if(_bytes!.count != 11) {
                throw KnxException.illformedTelegramForType
            }
            
            let days = ["??", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            let day     = Int((_bytes![8]  & 0xE0) >> 5)
            let hour    = (_bytes![8]  & 0x1F)
            let minutes = (_bytes![9]  & 0x3F)
            let seconds = (_bytes![10] & 0x3F)

            let time = String(format: "%@ %.2d:%.2d:%.2d",
                              days[day], hour, minutes, seconds)
            return time
            
            
        default:
            throw KnxException.unknownTelegramType
        }
    }

    /// Read-only property indicating whether the telegram contains a
    /// write request or value response, i.e. not a read request.
    open var isWriteRequestOrValueResponse : Bool {
        
        guard let bytes = _bytes else {
            
            return false
        }
        
        return ((bytes[6] & 0x03 == 0x00)
            && ((bytes[7] & 0xC0 == 0x80)) // write request
            || ((bytes[7] & 0xC0 == 0x40))) // value response
    }
    
    // MARK: Internal and private declarations
    
    fileprivate var _bytes:[UInt8]?
    fileprivate var _len:Int
    fileprivate var _type:KnxTelegramType
    
    internal var payload:[UInt8] {
        get {
            return _bytes!
        }
    }
    
}
