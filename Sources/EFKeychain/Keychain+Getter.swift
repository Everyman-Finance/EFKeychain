//
//  Keychain+Getter.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/14/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

/**
 An extension on *Keychain* that contains public getter methods.
 */
public extension Keychain {
    func integer(forKey key: String,
                        withAccessibility accessibility: KeychainAccessibility? = nil,
                        isSynchronizable: Bool = false) -> Int? {
        object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    func float(forKey key: String,
                      withAccessibility accessibility: KeychainAccessibility? = nil,
                      isSynchronizable: Bool = false) -> Float? {
        object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    func double(forKey key: String,
                       withAccessibility accessibility: KeychainAccessibility? = nil,
                       isSynchronizable: Bool = false) -> Double? {
        object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    func bool(forKey key: String,
                     withAccessibility accessibility: KeychainAccessibility? = nil,
                     isSynchronizable: Bool = false) -> Bool? {
        object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    /**
     Returns a string value for a specified key.
    
     - parameter forKey: The key to lookup data for.
     - parameter withAccessibility: Optional accessibility to use when retrieving the Keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with iCloud. If none is provided, will default to false
     - returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
     */
    func string(forKey key: String,
                       withAccessibility accessibility: KeychainAccessibility? = nil,
                       isSynchronizable: Bool = false) -> String? {
        guard let keychainData = data(forKey: key,
                                      withAccessibility: accessibility,
                                      isSynchronizable: isSynchronizable)
        else { return nil }
        
        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }
    
    /**
     Returns a Data object for a specified key.
    
     - parameter forKey: The key to lookup data for.
     - parameter withAccessibility: Optional accessibility to use when retrieving the Keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with iCloud. If none is provided, will default to false
     - returns: The Data object associated with the key if it exists. If no data exists, returns nil.
     */
    func data(forKey key: String,
              withAccessibility accessibility: KeychainAccessibility? = nil,
              isSynchronizable: Bool = false) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        
        // Limit search results to one
        keychainQueryDictionary[KeychainAttribute.SecMatchLimit.string] = kSecMatchLimitOne
        
        // Specify we want Data/CFData returned
        keychainQueryDictionary[KeychainAttribute.SecReturnData.string] = kCFBooleanTrue
        
        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    /**
     Returns a persistent data reference object for a specified key.
    
     - parameter forKey: The key to lookup data for.
     - parameter withAccessibility: Optional accessibility to use when retrieving the Keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with iCloud. If none is provided, will default to false
     - returns: The persistent data reference object associated with the key if it exists. If no data exists, returns nil.
     */
    func dataRef(forKey key: String,
                 withAccessibility accessibility: KeychainAccessibility? = nil,
                 isSynchronizable: Bool = false) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        
        // Limit search results to one
        keychainQueryDictionary[KeychainAttribute.SecMatchLimit.string] = kSecMatchLimitOne
        
        // Specify we want persistent Data/CFData reference returned
        keychainQueryDictionary[KeychainAttribute.SecReturnPersistentRef.string] = kCFBooleanTrue
        
        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
}
