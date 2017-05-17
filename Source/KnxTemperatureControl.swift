//
//  KnxTemperatureControl.swift
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
import SwiftyBeaver

/// Class allowing subscription on temperature.
open class KnxTemperatureControl: KnxTelegramResponseHandlerDelegate {

    // MARK: Public API:

    /**
     Initializes a new object.
     
     - parameter setOnOffAddress: The group address to use for turning light on and off.
     */

    public init(subscriptionAddress: KnxGroupAddress,
                responseHandler: KnxTemperatureResponseHandlerDelegate) {

        self.subscriptionAddress = subscriptionAddress

        self.responseHandler = responseHandler

        self._temperature = 0.0

        interface = KnxRouterInterface.getKnxRouterInstance()
        if let interface = interface {

            // TODO: Better error handling!
            try! interface.connect()
            interface.subscribeFor(address: subscriptionAddress,
                                   responseHandler: self)

            readValue()
        }
    }

    /**
     Trigger reading of sensor value.
     */
    open func readValue() {

        interface?.sendReadRequest(to: subscriptionAddress)
    }

    /// Read-only property holding the last received.
    open var temperature: Double {
        get {
            return _temperature
        }
    }

    /**
     Handler for telegram responses.
     
     - parameter sender: The interface the telegran were received on.
     - parameter telegram: The received telegram.
     */
    open func subscriptionResponse(sender: AnyObject?, telegram: KnxTelegram) {

        var type: KnxTelegramType

        let interface = sender as! KnxRouterInterface

        if interface == self.interface {
            type = KnxGroupAddressRegistry.getTypeForGroupAddress(address: subscriptionAddress)
            do {
                _temperature = try telegram.getValueAsType(type: type)
                responseHandler?.temperatureResponse(sender: subscriptionAddress,
                                                     level: _temperature)
            } catch KnxException.illformedTelegramForType {

                log.error("Catched...")
            } catch {
                // TODO: Improve error handling.
                log.error("Catched...")
            }
        }

        log.debug("HANDLING: \(telegram.payload)")
    }

    // MARK: Internal and private declarations

    fileprivate var subscriptionAddress: KnxGroupAddress

    fileprivate var interface: KnxRouterInterface?

    fileprivate var responseHandler: KnxTemperatureResponseHandlerDelegate?

    fileprivate var _temperature: Double

    fileprivate let log = SwiftyBeaver.self
}
