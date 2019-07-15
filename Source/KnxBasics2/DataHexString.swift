//
//  DataHexString.swift
//  KnxBasics2
//
//  Created by Trond Kjeldås on 14/05/2017.
//  Copyright © 2017 Trond Kjeldås. All rights reserved.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
