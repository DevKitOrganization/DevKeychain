//
//  InternetPasswordTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.InternetPassword

struct InternetPasswordTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func passwordReturnsCorrectString() throws {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomAlphanumericString()

        let data = try #require(password.data(using: .utf16))
        let internetPassword = InternetPassword(
            server: server,
            account: account,
            data: data,
            accessibility: randomAccessibility(),
        )
        #expect(internetPassword.password(using: .utf16) == password)
    }


    @Test
    mutating func passwordReturnsNilWhenStringEncodingIsIncorrect() throws {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData(count: 5)

        let internetPassword = InternetPassword(
            server: server,
            account: account,
            data: data,
            accessibility: randomAccessibility(),
        )
        #expect(internetPassword.password(using: .utf32) == nil)
    }


    @Test
    mutating func queryIsCorrect() {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()

        let internetPassword = InternetPassword(
            server: server,
            account: account,
            data: randomData(),
            accessibility: randomAccessibility(),
        )
        let query = internetPassword.query

        #expect(query.server == server)
        #expect(query.account == account)
    }


    @Test
    mutating func initWithAttributesThrowsErrorIfKeyIsMissing() {
        let dictionary: [CFString: Any] = [
            kSecAttrAccessible: randomAccessibility().attributeValue,
            kSecAttrServer: randomAlphanumericString(),
            kSecAttrAccount: randomAlphanumericString(),
            kSecValueData: randomData(),
        ]

        for attribute in dictionary.keys {
            var attributes = dictionary
            attributes.removeValue(forKey: attribute)

            #expect(throws: KeychainItemMappingError.attributeNotFound(attribute as String)) {
                _ = try InternetPassword(attributes: attributes)
            }
        }
    }


    @Test
    mutating func initWithAttributesThrowsErrorIfKeyIsIncorrectlyTyped() {
        let dictionary: [CFString: Any] = [
            kSecAttrAccessible: randomAccessibility().attributeValue,
            kSecAttrServer: randomAlphanumericString(),
            kSecAttrAccount: randomAlphanumericString(),
            kSecValueData: randomData(),
        ]

        let keysAndTypes: [CFString: Any.Type] = [
            kSecAttrServer: String.self,
            kSecAttrAccount: String.self,
            kSecValueData: Data.self,
        ]

        for (key, type) in keysAndTypes {
            var attributes = dictionary
            attributes[key] = randomInt(in: .min ... .max)

            #expect(throws: KeychainItemMappingError.attributeTypeMismatch(attribute: key as String, type: type)) {
                _ = try InternetPassword(attributes: attributes)
            }
        }

        var attributes = dictionary
        attributes[kSecAttrAccessible] = randomInt(in: .min ... .max)
        #expect(
            throws: KeychainItemMappingError.attributeTypeMismatch(
                attribute: kSecAttrAccessible as String,
                type: String.self,
            )
        ) {
            _ = try InternetPassword(attributes: attributes)
        }
    }


    @Test
    mutating func initWithAttributesThrowsErrorIfAccessibilityIsUnrecognized() {
        let attributes: [CFString: Any] = [
            kSecAttrAccessible: randomAlphanumericString(),
            kSecAttrServer: randomAlphanumericString(),
            kSecAttrAccount: randomAlphanumericString(),
            kSecValueData: randomData(),
        ]

        #expect(
            throws: KeychainItemMappingError.attributeTypeMismatch(
                attribute: kSecAttrAccessible as String,
                type: KeychainItemAccessibility.self,
            )
        ) {
            _ = try InternetPassword(attributes: attributes)
        }
    }


    @Test
    mutating func initWithAttributesSetsProperties() throws {
        let accessibility = randomAccessibility()
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let expected = InternetPassword(server: server, account: account, data: data, accessibility: accessibility)
        let actual = try InternetPassword(
            attributes: [
                kSecAttrAccessible: accessibility.attributeValue,
                kSecAttrServer: server,
                kSecAttrAccount: account,
                kSecValueData: data,
            ]
        )

        #expect(actual == expected)
    }
}


struct InternetPassword_AdditionAttributesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() throws {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = InternetPassword.AdditionAttributes(server: server, account: account, data: data)
        #expect(attributes.server == server)
        #expect(attributes.account == account)
        #expect(attributes.data == data)
        #expect(attributes.accessibility == nil)
    }


    @Test
    mutating func initWithAccessibilitySetsAccessibility() throws {
        let accessibility = randomAccessibility()

        let attributes = InternetPassword.AdditionAttributes(
            server: randomAlphanumericString(),
            account: randomAlphanumericString(),
            data: randomData(),
            accessibility: accessibility,
        )
        #expect(attributes.accessibility == accessibility)
    }


    @Test
    mutating func initWithPasswordReturnsNilWhenEncodingIsIncorrect() throws {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomString(withCharactersFrom: "⏳💣💥")

        let attributes = InternetPassword.AdditionAttributes(
            server: server,
            account: account,
            password: password,
            encoding: .ascii,
        )
        #expect(attributes == nil)
    }


    @Test
    mutating func initWithPasswordSetsPropertiesWhenEncodingIsCorrect() throws {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomString(withCharactersFrom: "⏳💣💥")
        let expectedData = try #require(password.data(using: .utf8))

        let attributes = try #require(
            InternetPassword.AdditionAttributes(
                server: server,
                account: account,
                password: password,
                encoding: .utf8,
            )
        )

        #expect(attributes.server == server)
        #expect(attributes.account == account)
        #expect(attributes.data == expectedData)
    }


    @Test
    mutating func attributesDictionaryIsCorrectWhenAccessibilityIsNil() {
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = InternetPassword.AdditionAttributes(server: server, account: account, data: data)

        let expectedDictionary: [CFString: Any] = [
            kSecAttrAccount: account,
            kSecAttrServer: server,
            kSecClass: kSecClassInternetPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: data,
        ]

        #expect(attributes.attributesDictionary as CFDictionary == expectedDictionary as CFDictionary)
    }


    @Test
    mutating func attributesDictionaryIncludesAccessibilityWhenSet() {
        let accessibility = randomAccessibility()
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = InternetPassword.AdditionAttributes(
            server: server,
            account: account,
            data: data,
            accessibility: accessibility,
        )

        let expectedDictionary: [CFString: Any] = [
            kSecAttrAccessible: accessibility.attributeValue,
            kSecAttrAccount: account,
            kSecAttrServer: server,
            kSecClass: kSecClassInternetPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: data,
        ]

        #expect(attributes.attributesDictionary as CFDictionary == expectedDictionary as CFDictionary)
    }


    @Test
    mutating func mapThrowsWhenObjectIsNonDictionary() {
        let attributes = InternetPassword.AdditionAttributes(
            server: randomAlphanumericString(),
            account: randomAlphanumericString(),
            data: randomData(),
        )

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            try attributes.mapAddedItem(kCFNull)
        }
    }


    @Test
    mutating func mapRethrowsWhenInitWithAttributesThrows() {
        let attributes = InternetPassword.AdditionAttributes(
            server: randomAlphanumericString(),
            account: randomAlphanumericString(),
            data: randomData(),
        )

        #expect(throws: KeychainItemMappingError.self) {
            try attributes.mapAddedItem([:] as CFDictionary)
        }
    }


    @Test
    mutating func mapReturnsInitializedValue() throws {
        let accessibility = randomAccessibility()
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = InternetPassword.AdditionAttributes(server: server, account: account, data: data)
        let expected = InternetPassword(server: server, account: account, data: data, accessibility: accessibility)
        let actual = try attributes.mapAddedItem(
            [
                kSecAttrAccessible: accessibility.attributeValue,
                kSecAttrServer: server,
                kSecAttrAccount: account,
                kSecValueData: data,
            ] as CFDictionary
        )

        #expect(actual == expected)
    }
}


struct InternetPassword_QueryTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() throws {
        let server = randomOptional(randomAlphanumericString())
        let account = randomOptional(randomAlphanumericString())
        let accessibility = randomOptional(randomAccessibility())

        let query = InternetPassword.Query(server: server, account: account, accessibility: accessibility)
        #expect(query.server == server)
        #expect(query.account == account)
        #expect(query.accessibility == accessibility)
    }


    @Test
    mutating func attributesDictionaryIsCorrect() throws {
        let accessibility = randomAccessibility()
        let server = randomAlphanumericString()
        let account = randomAlphanumericString()

        let fullAttributesDictionary: [CFString: Any] = [
            kSecAttrAccessible: accessibility.attributeValue,
            kSecAttrAccount: account,
            kSecAttrServer: server,
            kSecClass: kSecClassInternetPassword,
            kSecUseDataProtectionKeychain: true,
        ]

        for isAccessibilityNil in [false, true] {
            for isServerNil in [false, true] {
                for isAccountNil in [false, true] {
                    let query = InternetPassword.Query(
                        server: isServerNil ? nil : server,
                        account: isAccountNil ? nil : account,
                        accessibility: isAccessibilityNil ? nil : accessibility,
                    )

                    var expectedDictionary = fullAttributesDictionary
                    if isAccessibilityNil {
                        expectedDictionary.removeValue(forKey: kSecAttrAccessible)
                    }

                    if isServerNil {
                        expectedDictionary.removeValue(forKey: kSecAttrServer)
                    }

                    if isAccountNil {
                        expectedDictionary.removeValue(forKey: kSecAttrAccount)
                    }

                    #expect(query.attributesDictionary as CFDictionary == expectedDictionary as CFDictionary)
                }
            }
        }
    }


    @Test
    mutating func returnDictionaryIsCorrect() throws {
        let query = InternetPassword.Query(
            server: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString()),
        )

        let expectedDictionary = [
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ]

        #expect(query.returnDictionary as CFDictionary == expectedDictionary as CFDictionary)
    }


    @Test
    mutating func mapThrowsErrorWhenRawItemsIsIncorrectType() {
        let query = InternetPassword.Query(
            server: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString()),
        )

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            _ = try query.mapMatchingItems(kCFNull)
        }
    }


    @Test
    mutating func mapReturnsItemsWithCorrectValues() throws {
        let query = InternetPassword.Query(
            server: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString()),
        )

        let expectedItems = Array(count: randomInt(in: 3 ... 5)) {
            InternetPassword(
                server: randomAlphanumericString(),
                account: randomAlphanumericString(),
                data: randomData(),
                accessibility: randomAccessibility(),
            )
        }

        let rawItems: [[CFString: Any]] = expectedItems.map { item in
            [
                kSecAttrAccessible: item.accessibility.attributeValue,
                kSecAttrAccount: item.account,
                kSecAttrServer: item.server,
                kSecValueData: item.data,
            ]
        }

        for (rawItem, expectedItem) in zip(rawItems, expectedItems) {
            #expect(try query.mapMatchingItems(rawItem as CFDictionary) == [expectedItem])
        }

        #expect(try query.mapMatchingItems(rawItems as CFArray) == expectedItems)
    }
}
