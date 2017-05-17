//
//  KnxTelegramResponseDelegate.swift
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

/// Delegate protocol for KnxDimmerControl delegates.
public protocol KnxTelegramResponseHandlerDelegate {

    /**
     Handler for received telegrams.
     
     - parameter sender: The interface the telegram were received on.
     - parameter telegram: The received telegran.
     */
    func subscriptionResponse(sender: AnyObject?, telegram: KnxTelegram)
}
