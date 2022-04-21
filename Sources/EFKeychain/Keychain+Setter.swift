//
//  Keychain+Setter.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/14/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

/**
 An extension on *Keychain* that contains public setter methods.
 */
public extension Keychain {
    @discardableResult func set(_ value: Int,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult func set(_ value: Float,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult func set(_ value: Double,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult func set(_ value: Bool,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    /**
     Save a String value to Keychain associated with a specified key. If a String value already exists for the given key, the string will be overwritten with the new value.
     
     - parameter value: The String value to save.
     - parameter forKey: The key to save the String under.
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with iCloud. If none is provided, will default to false
     - returns: true if the save was successful, false otherwise.
     */
    @discardableResult func set(_ value: String,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        if let data = value.data(using: .utf8) {
            return set(data, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }
    
    /**
     Save a Codable object to Keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
     
     - parameter value: The Codable object to save.
     - parameter forKey: The key to save the object under.
     - parameter withAccessibility: Optional accessibility to use when setting the Keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with iCloud. If none is provided, will default to false
     - returns: true if the save was successful, false otherwise.
     */
    @discardableResult func create<T: Codable>(_ value: T,
                                               forKey key: String,
                                               withAccessibility accessibility: KeychainAccessibility? = nil,
                                               isSynchronizable: Bool = false) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else { return false }
        return set(data, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    /**
     Save a Data object to Keychain associated with a specified key. If data already exists for the given key, the data will be overwritten with the new value.
     
     - parameter value: The Data object to save.
     - parameter forKey: The key to save the object under.
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: true if the save was successful, false otherwise.
     */
    @discardableResult func set(_ value: Data,
                                forKey key: String,
                                withAccessibility accessibility: KeychainAccessibility? = nil,
                                isSynchronizable: Bool = false) -> Bool {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        
        keychainQueryDictionary[KeychainAttribute.SecValueData.string] = value
        
        if let accessibility = accessibility {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = accessibility.attributeValue
        } else {
            // Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = KeychainAccessibility.whenUnlocked.attributeValue
        }
        
        let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value,
                          forKey: key,
                          withAccessibility: accessibility,
                          isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }
}
