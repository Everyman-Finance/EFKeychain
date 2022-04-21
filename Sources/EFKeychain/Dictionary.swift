//
//  Dictionary.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/21/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

public extension Dictionary where Key == String, Value == Any {
    /// Removes value for a given *KeychainAttribute*
    mutating func removeValue(for attribute: KeychainAttribute) {
        removeValue(forKey: attribute.string)
    }
}
