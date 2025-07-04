//
//  Dictionary+KeychainItemMappingTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.Keychain

struct Dictionary_KeychainItemMappingTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func valueForKeychainAttributeThrowsWhenAttributeIsNotFound() {
        let keychainDictionary = randomKeychainDictionary() as [CFString: Any]

        let attribute = randomBasicLatinString(count: 10)
        #expect(throws: KeychainItemMappingError.attributeNotFound(attribute)) {
            _ = try keychainDictionary.value(forKeychainAttribute: attribute as CFString, type: String.self)
        }
    }


    @Test
    mutating func valueForKeychainAttributeThrowsWhenAttributeHasIncorrectType() {
        let keychainDictionary = randomKeychainDictionary() as [CFString: Any]

        let attribute = randomElement(in: keychainDictionary.keys)! as String
        #expect(throws: KeychainItemMappingError.attributeTypeMismatch(attribute: attribute, type: UUID.self)) {
            _ = try keychainDictionary.value(forKeychainAttribute: attribute as CFString, type: UUID.self)
        }
    }


    @Test
    mutating func valueForKeychainAttributeReturnsCorrectValue() throws {
        let keychainDictionary = randomKeychainDictionary() as [CFString: Any]

        let (attribute, expectedValue) = randomElement(in: keychainDictionary)!
        let actualValue = try keychainDictionary.value(forKeychainAttribute: attribute as CFString, type: String.self)
        #expect(actualValue == expectedValue as? String)
    }
}
