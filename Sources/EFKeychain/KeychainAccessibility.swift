//
//  KeychainAccessibility.swift
//  EFKeychain
//
//  Created by Justin Trautman on 4/14/22.
//  Copyright © 2022 Everyman Finance LLC. All rights reserved.
//

import Foundation

protocol KeychainAttributeRepresentable {
	var attributeValue: CFString { get }
}

/// Enum that defines the accessibility of a Keychain object.
public enum KeychainAccessibility {
	/// Data in Keychain can be accessed regardless of whether the device is unlocked
	case always
	/// Data in Keychain cannot be accessed after a restart until the device has been unlocked by the user
	case afterFirstUnlock
	/// Data in Keychain cannot be accessed after a restart until the device has been unlocked by the user
	case whenUnlocked
	
	static func accessibilityForValue(_ attribute: CFString) -> KeychainAccessibility? {
		for (key, value) in accessibilityLookup {
			if value == attribute { return key }
		}
		
		return nil
	}
}

private let accessibilityLookup: [KeychainAccessibility: CFString] = {
	let lookup: [KeychainAccessibility: CFString] =
		[
		.always: 		   kSecAttrAccessibleAlways,
		.afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock,
		.whenUnlocked: 	   kSecAttrAccessibleWhenUnlocked
		]
	
	return lookup
}()

extension KeychainAccessibility: KeychainAttributeRepresentable {
	internal var attributeValue: CFString { accessibilityLookup[self]! }
}
