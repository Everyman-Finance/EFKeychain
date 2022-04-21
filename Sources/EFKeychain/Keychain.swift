//
//  Keychain.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/14/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

// MARK: - Keychain Attribute Strings

open class Keychain {
    
    // MARK: - Properties
		
    /// Keychain access similar to UserDefaults
	public static let standard = Keychain()
    
    /**
     ServiceName is used for the kSecAttrService property to uniquely identify this
     Keychain accessor. If no service name is specified, the bundle identifier will be used.
     */
    private (set) public var serviceName: String
    
    /**
     AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain
     Access Group this entry belongs to. This allows you to use a shared Keychain.
     */
    private (set) public var accessGroup: String?
    
    private static let defaultServiceName: String = {
        Bundle.main.bundleIdentifier ?? "EFKeychain"
    }()
    
    // MARK: - init
    
    private convenience init() {
        self.init(serviceName: Keychain.defaultServiceName)
    }
    
    /**
     Creates a custom instance of Keychain with a service name and optional access group.
     
     - parameter serviceName - *String*: The ServiceName for this instance.
     Used to uniquely identify all keys stored using this keychain wrapper instance.
     
     - parameter accessGroup - *String*: Optional access group for this instance. Use a matching group string between applications to allow shared keychain access.
     */
    public init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
	
    /**
     Checks if keychain data exists for a specified key.

      - parameter forKey: The key to check for.
      - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
      - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
      - returns: True if a value exists for the key. False otherwise.
     */
    public func hasValue(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        return data(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable) != nil
    }
    
    public func accessibilityOfKey(_ key: String) -> KeychainAccessibility? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)

        // Remove accessibility attribute
        keychainQueryDictionary.removeValue(for: .SecAttrAccessible)
        
        // Limit search results to one
        keychainQueryDictionary[KeychainAttribute.SecMatchLimit.string] = kSecMatchLimitOne

        // Specify we want SecAttrAccessible returned
        keychainQueryDictionary[KeychainAttribute.SecReturnAttributes.string] = kCFBooleanTrue

        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        guard status == noErr, let resultsDictionary = result as? [String:AnyObject], let accessibilityAttrValue = resultsDictionary[KeychainAttribute.SecAttrAccessible.string] as? String else {
            return nil
        }
    
        return KeychainAccessibility.accessibilityForValue(accessibilityAttrValue as CFString)
    }

    /// Get the keys of all keychain entries matching the current ServiceName and AccessGroup if one is set.
    public func allKeys() -> Set<String> {
        var keychainQueryDictionary: [String:Any] = [
            KeychainAttribute.SecClass.string: kSecClassGenericPassword,
            KeychainAttribute.SecAttrService.string: serviceName,
            KeychainAttribute.SecReturnAttributes.string: kCFBooleanTrue!,
            KeychainAttribute.SecMatchLimit.string: kSecMatchLimitAll,
        ]

        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessGroup.string] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        guard status == errSecSuccess else { return [] }

        var keys = Set<String>()
        if let results = result as? [[AnyHashable: Any]] {
            for attributes in results {
                if let accountData = attributes[KeychainAttribute.SecAttrAccount] as? Data,
                    let key = String(data: accountData, encoding: String.Encoding.utf8) {
                    keys.insert(key)
                } else if let accountData = attributes[kSecAttrAccount] as? Data,
                    let key = String(data: accountData, encoding: String.Encoding.utf8) {
                    keys.insert(key)
                }
            }
        }
        return keys
    }
    
    // MARK: Public Getters
    
    public func integer(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Int? {
        return object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    public func float(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Float? {
        return object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    public func double(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Double? {
        return object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    public func bool(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool? {
        return object(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    /**
     Returns a string value for a specified key.
    
     - parameter forKey: The key to lookup data for.
     - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
     */
    public func string(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> String? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable) else {
            return nil
        }
        
        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }
    
    public func object<T: Codable>(forKey key: String,
                                 withAccessibility accessibility: KeychainAccessibility? = nil,
                                 isSynchronizable: Bool = false) -> T? {
        guard let data = data(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }

    
    /**
     Returns a Data object for a specified key.
    
     - parameter forKey: The key to lookup data for.
     - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: The Data object associated with the key if it exists. If no data exists, returns nil.
     */
    public func data(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Data? {
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
     - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: The persistent data reference object associated with the key if it exists. If no data exists, returns nil.
     */
    public func dataRef(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Data? {
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
    
    // MARK: Public Setters
    
    @discardableResult public func set(_ value: Int, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        return create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult public func set(_ value: Float, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        return create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult public func set(_ value: Double, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        return create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    @discardableResult public func set(_ value: Bool, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        return create(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }

    /**
     Save a String value to the keychain associated with a specified key. If a String value already exists for the given key, the string will be overwritten with the new value.
    
     - parameter value: The String value to save.
     - parameter forKey: The key to save the String under.
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: True if the save was successful, false otherwise.
     */
    @discardableResult open func set(_ value: String, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        if let data = value.data(using: .utf8) {
            return set(data, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }

    /**
     Save an NSCoding compliant object to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    
     - parameter value: The NSCoding compliant object to save.
     - parameter forKey: The key to save the object under.
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: True if the save was successful, false otherwise.
     */
    @discardableResult public func create<T: Codable>(_ value: T, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else { return false }
        return set(data, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }

    /**
     Save a Data object to the keychain associated with a specified key. If data already exists for the given key, the data will be overwritten with the new value.
    
     - parameter value: The Data object to save.
     - parameter forKey: The key to save the object under.
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: True if the save was successful, false otherwise.
     */
    @discardableResult public func set(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        var keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        
        keychainQueryDictionary[KeychainAttribute.SecValueData.string] = value
        
        if let accessibility = accessibility {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = accessibility.attributeValue
        } else {
            // Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = KeychainAccessibility.whenUnlocked.attributeValue
        }
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }

    /**
     Remove an object associated with a specified key. If re-using a key but with a different accessibility, first remove the previous key value using removeObjectForKey(:withAccessibility) using the same accessibility it was saved with.
    
     - parameter forKey: The key value to remove data for.
     - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: True if successful, false otherwise.
     */
    @discardableResult public func removeObject(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        let keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)

        // Delete
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)

        return status == errSecSuccess
    }

    /// Remove all keychain data added through KeychainWrapper. This will only delete items matching the current ServiceName and AccessGroup if one is set.
    @discardableResult public func removeAllKeys() -> Bool {
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:Any] = [KeychainAttribute.SecClass.string: kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[KeychainAttribute.SecAttrService.string] = serviceName
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessGroup.string] = accessGroup
        }
        
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)
        
        return status == errSecSuccess
    }
    
    /**
     Remove all keychain data, including data not added through keychain wrapper.
    
     - Warning: This may remove custom keychain entries you did not add via SwiftKeychainWrapper.
    */
    public class func wipeKeychain() {
        deleteKeychainSecClass(kSecClassGenericPassword) // Generic password items
        deleteKeychainSecClass(kSecClassInternetPassword) // Internet password items
        deleteKeychainSecClass(kSecClassCertificate) // Certificate items
        deleteKeychainSecClass(kSecClassKey) // Cryptographic key items
        deleteKeychainSecClass(kSecClassIdentity) // Identity items
    }

    // MARK: - Private Methods
    
    /// Remove all items for a given Keychain Item Class
    @discardableResult private class func deleteKeychainSecClass(_ secClass: AnyObject) -> Bool {
        let query = [KeychainAttribute.SecClass.string: secClass]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Update existing data associated with a specified key name. The existing data will be overwritten by the new data.
    private func update(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> Bool {
        var keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        let updateDictionary = [KeychainAttribute.SecValueData.string: value]
        
        // on update, only set accessibility if passed in
        if let accessibility = accessibility {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = accessibility.attributeValue
        }
        
        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)

        return status == errSecSuccess
    }

    /**
     Setup the keychain query dictionary used to access the keychain on iOS for a specified key name. Takes into account the Service Name and Access Group if one is set.
    
     - parameter forKey: The key this query is for
     - parameter withAccessibility: Optional accessibility to use when setting the keychain item. If none is provided, will default to .WhenUnlocked
     - parameter isSynchronizable: A bool that describes if the item should be synchronizable, to be synched with the iCloud. If none is provided, will default to false
     - returns: A dictionary with all the needed properties setup to access the keychain on iOS
     */
    private func setupKeychainQueryDictionary(forKey key: String, withAccessibility accessibility: KeychainAccessibility? = nil, isSynchronizable: Bool = false) -> [String: Any] {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String: Any] = [KeychainAttribute.SecClass.string: kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[KeychainAttribute.SecAttrService.string] = serviceName
        
        // Only set accessibility if its passed in, we don't want to default it here in case the user didn't want it set
        if let accessibility = accessibility {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessible.string] = accessibility.attributeValue
        }
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[KeychainAttribute.SecAttrAccessGroup.string] = accessGroup
        }
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        
        keychainQueryDictionary[KeychainAttribute.SecAttrGeneric.string]        = encodedIdentifier
        keychainQueryDictionary[KeychainAttribute.SecAttrAccount.string]        = encodedIdentifier
        keychainQueryDictionary[KeychainAttribute.SecAttrSynchronizable.string] = isSynchronizable ? kCFBooleanTrue : kCFBooleanFalse
        
        return keychainQueryDictionary
    }
}
