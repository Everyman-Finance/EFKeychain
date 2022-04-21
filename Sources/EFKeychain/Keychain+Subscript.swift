//
//  Keychain+Subscript.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/20/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

// MARK: - Keychain CRUD

public extension Keychain {
    
    /// Removes an objects from Keychain given a Key
    func removeObject(forKey key: Key) {
        removeObject(forKey: key.rawValue)
    }
    
    /// Returns a Data object from Keychain given a Key
    func data(forKey key: Key) -> Data? {
        data(forKey: key.rawValue)
    }
    
    /// Returns a Bool object from Keychain given a Key
    func bool(forKey key: Key) -> Bool? {
        bool(forKey: key.rawValue)
    }
    
    /// Returns a Integer object from Keychain given a Key
    func integer(forKey key: Key) -> Int? {
        integer(forKey: key.rawValue)
    }
    
    /// Returns a Float object from Keychain given a Key
    func float(forKey key: Key) -> Float? {
        float(forKey: key.rawValue)
    }
    
    /// Returns a Double object from Keychain given a Key
    func double(forKey key: Key) -> Double? {
        double(forKey: key.rawValue)
    }
    
    /// Returns a String object from Keychain given a Key
    func string(forKey key: Key) -> String? {
        string(forKey: key.rawValue)
    }
}

// MARK: - Subscript

public extension Keychain {
    
    subscript(key: Key) -> String? {
        get { return string(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }

    subscript(key: Key) -> Bool? {
        get { return bool(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }

    subscript(key: Key) -> Int? {
        get { return integer(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }

    subscript(key: Key) -> Double? {
        get { return double(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }

    subscript(key: Key) -> Float? {
        get { return float(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }
    
    subscript(key: Key) -> Data? {
        get { return data(forKey: key) }
        set { if let value = newValue { set(value, forKey: key.rawValue) }}
    }
}
