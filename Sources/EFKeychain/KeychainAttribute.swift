//
//  KeychainAttribute.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/21/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

public enum KeychainAttribute {
    case SecMatchLimit
    case SecReturnData
    case SecReturnPersistentRef
    case SecValueData
    case SecAttrAccessible
    case SecClass
    case SecAttrService
    case SecAttrGeneric
    case SecAttrAccount
    case SecAttrAccessGroup
    case SecReturnAttributes
    case SecAttrSynchronizable
    
    var string: String {
        switch self {
        case .SecMatchLimit:          return kSecMatchLimit as String
        case .SecReturnData:          return kSecReturnData as String
        case .SecReturnPersistentRef: return kSecReturnPersistentRef as String
        case .SecValueData:           return kSecValueData as String
        case .SecAttrAccessible:      return kSecAttrAccessible as String
        case .SecClass:               return kSecClass as String
        case .SecAttrService:         return kSecAttrService as String
        case .SecAttrGeneric:         return kSecAttrGeneric as String
        case .SecAttrAccount:         return kSecAttrAccount as String
        case .SecAttrAccessGroup:     return kSecAttrAccessGroup as String
        case .SecReturnAttributes:    return kSecReturnAttributes as String
        case .SecAttrSynchronizable:  return kSecAttrSynchronizable as String
        }
    }
}
