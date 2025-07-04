//
//  GenericPasswordTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.GenericPassword

struct GenericPasswordTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func passwordReturnsCorrectString() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomAlphanumericString()

        let data = try #require(password.data(using: .utf16))
        let genericPassword = GenericPassword(service: service, account: account, data: data)
        #expect(genericPassword.password(using: .utf16) == password)
    }


    @Test
    mutating func passwordReturnsNilWhenStringEncodingIsIncorrect() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData(count: 5)

        let genericPassword = GenericPassword(service: service, account: account, data: data)
        #expect(genericPassword.password(using: .utf32) == nil)
    }


    @Test
    mutating func queryIsCorrect() {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()

        let genericPassword = GenericPassword(service: service, account: account, data: randomData())
        let query = genericPassword.query

        #expect(query.service == service)
        #expect(query.account == account)
    }


    @Test
    mutating func initWithAttributesThrowsErrorIfKeyIsMissing() {
        let dictionary: [CFString: Any] = [
            kSecAttrService: randomAlphanumericString(),
            kSecAttrAccount: randomAlphanumericString(),
            kSecValueData: randomData(),
        ]

        for attribute in dictionary.keys {
            var attributes = dictionary
            attributes.removeValue(forKey: attribute)

            #expect(throws: KeychainItemMappingError.attributeNotFound(attribute as String)) {
                _ = try GenericPassword(attributes: attributes)
            }
        }
    }


    @Test
    mutating func initWithAttributesThrowsErrorIfKeyIsIncorrectlyTypes() {
        let dictionary: [CFString: Any] = [
            kSecAttrService: randomAlphanumericString(),
            kSecAttrAccount: randomAlphanumericString(),
            kSecValueData: randomData(),
        ]

        let keysAndTypes: [CFString: Any.Type] = [
            kSecAttrService: String.self,
            kSecAttrAccount: String.self,
            kSecValueData: Data.self,
        ]

        for (key, type) in keysAndTypes {
            var attributes = dictionary
            attributes[key] = random(Int.self, in: .min ... .max)

            #expect(throws: KeychainItemMappingError.attributeTypeMismatch(attribute: key as String, type: type)) {
                _ = try GenericPassword(attributes: attributes)
            }
        }
    }


    @Test
    mutating func initWithAttributesSetsProperties() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let expected = GenericPassword(service: service, account: account, data: data)
        let actual = try GenericPassword(
            attributes: [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecValueData: data,
            ]
        )

        #expect(actual == expected)
    }
}


struct GenericPassword_AdditionAttributesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = GenericPassword.AdditionAttributes(service: service, account: account, data: data)
        #expect(attributes.service == service)
        #expect(attributes.account == account)
        #expect(attributes.data == data)
    }


    @Test
    mutating func initWithPasswordReturnsNilWhenEncodingIsIncorrect() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomString(withCharactersFrom: "⏳💣💥")

        let attributes = GenericPassword.AdditionAttributes(
            service: service,
            account: account,
            password: password,
            encoding: .ascii
        )
        #expect(attributes == nil)
    }


    @Test
    mutating func initWithPasswordSetsPropertiesWhenEncodingIsCorrect() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let password = randomString(withCharactersFrom: "⏳💣💥")
        let expectedData = try #require(password.data(using: .utf8))

        let attributes = try #require(
            GenericPassword.AdditionAttributes(
                service: service,
                account: account,
                password: password,
                encoding: .utf8
            )
        )

        #expect(attributes.service == service)
        #expect(attributes.account == account)
        #expect(attributes.data == expectedData)
    }


    @Test
    mutating func attributesDictionaryIsCorrect() {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = GenericPassword.AdditionAttributes(service: service, account: account, data: data)

        let expectedDictionary: [CFString: Any] = [
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: data,
        ]

        #expect(attributes.attributesDictionary as CFDictionary == expectedDictionary as CFDictionary)
    }


    @Test
    mutating func mapThrowsWhenObjectIsNonDictionary() {
        let attributes = GenericPassword.AdditionAttributes(
            service: randomAlphanumericString(),
            account: randomAlphanumericString(),
            data: randomData()
        )

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            try attributes.mapAddedItem(kCFNull)
        }
    }


    @Test
    mutating func mapRethrowsWhenInitWithAttributesThrows() {
        let attributes = GenericPassword.AdditionAttributes(
            service: randomAlphanumericString(),
            account: randomAlphanumericString(),
            data: randomData()
        )

        #expect(throws: KeychainItemMappingError.self) {
            try attributes.mapAddedItem([:] as CFDictionary)
        }
    }


    @Test
    mutating func mapReturnsInitializedValue() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()
        let data = randomData()

        let attributes = GenericPassword.AdditionAttributes(service: service, account: account, data: data)
        let expected = GenericPassword(service: service, account: account, data: data)
        let actual = try attributes.mapAddedItem(
            [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecValueData: data,
            ] as CFDictionary
        )

        #expect(actual == expected)
    }
}


struct GenericPassword_QueryTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() throws {
        let service = randomOptional(randomAlphanumericString())
        let account = randomOptional(randomAlphanumericString())

        let query = GenericPassword.Query(service: service, account: account)
        #expect(query.service == service)
        #expect(query.account == account)
    }


    @Test
    mutating func attributesDictionaryIsCorrect() throws {
        let service = randomAlphanumericString()
        let account = randomAlphanumericString()

        let fullAttributesDictionary: [CFString: Any] = [
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
        ]

        for isServiceNil in [false, true] {
            for isAccountNil in [false, true] {
                let query = GenericPassword.Query(
                    service: isServiceNil ? nil : service,
                    account: isAccountNil ? nil : account
                )

                var expectedDictionary = fullAttributesDictionary
                if isServiceNil {
                    expectedDictionary.removeValue(forKey: kSecAttrService)
                }

                if isAccountNil {
                    expectedDictionary.removeValue(forKey: kSecAttrAccount)
                }

                #expect(query.attributesDictionary as CFDictionary == expectedDictionary as CFDictionary)
            }
        }
    }


    @Test
    mutating func returnDictionaryIsCorrect() throws {
        let query = GenericPassword.Query(
            service: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString())
        )

        let expectedDictionary = [
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ]

        #expect(query.returnDictionary as CFDictionary == expectedDictionary as CFDictionary)
    }


    @Test
    mutating func mapThrowsErrorWhenRawItemsIsIncorrectType() {
        let query = GenericPassword.Query(
            service: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString())
        )

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            _ = try query.mapMatchingItems(kCFNull)
        }
    }


    @Test
    mutating func mapReturnsItemsWithCorrectValues() throws {
        let query = GenericPassword.Query(
            service: randomOptional(randomAlphanumericString()),
            account: randomOptional(randomAlphanumericString())
        )

        let expectedItems = Array(count: random(Int.self, in: 3 ... 5)) {
            GenericPassword(
                service: randomAlphanumericString(),
                account: randomAlphanumericString(),
                data: randomData()
            )
        }

        let rawItems: [[CFString: Any]] = expectedItems.map { item in
            [
                kSecAttrAccount: item.account,
                kSecAttrService: item.service,
                kSecValueData: item.data,
            ]
        }

        for (rawItem, expectedItem) in zip(rawItems, expectedItems) {
            #expect(try query.mapMatchingItems(rawItem as CFDictionary) == [expectedItem])
        }

        #expect(try query.mapMatchingItems(rawItems as CFArray) == expectedItems)
    }
}
