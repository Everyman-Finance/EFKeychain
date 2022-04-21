//
//  Key.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/20/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

public extension Keychain {
    
    struct Key: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }
}
