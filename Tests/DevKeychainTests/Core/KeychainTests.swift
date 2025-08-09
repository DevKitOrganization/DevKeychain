//
//  KeychainTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.Keychain

struct KeychainTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func noArgInitCreatesStandardKeychainServices() {
        let keychain = Keychain()
        #expect(keychain.keychainService is StandardKeychainServices)
    }


    @Test
    func initSetsKeychainServices() {
        let keychainService = MockKeychainServices()
        let keychain = Keychain(keychainService: keychainService)
        #expect(keychain.keychainService as? MockKeychainServices === keychainService)
    }


    @Test
    mutating func addItemRethrowsErrorWhenKeychainServiceThrowsError() {
        let expectedError = randomError()

        let keychainService = MockKeychainServices()
        keychainService.addItemStub = ThrowingStub(defaultResult: .failure(expectedError))
        let keychain = Keychain(keychainService: keychainService)

        let attributes = MockKeychainItemAdditionAttributes<Void>()
        attributes.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])

        #expect(throws: expectedError) {
            try keychain.addItem(with: attributes)
        }
    }


    @Test
    mutating func addItemThrowsDataCorruptedErrorWhenKeychainServiceReturnsNil() {
        let keychainService = MockKeychainServices()
        keychainService.addItemStub = ThrowingStub(defaultResult: .success(nil))
        let keychain = Keychain(keychainService: keychainService)

        let attributes = MockKeychainItemAdditionAttributes<Void>()
        attributes.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            try keychain.addItem(with: attributes)
        }
    }


    @Test
    mutating func addItemRethrowsErrorWhenConversionThrowsError() {
        let keychainService = MockKeychainServices()
        keychainService.addItemStub = ThrowingStub(defaultResult: .success(randomKeychainDictionary() as CFDictionary))
        let keychain = Keychain(keychainService: keychainService)

        let attributes = MockKeychainItemAdditionAttributes<Void>()
        attributes.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])

        let expectedError = randomError()
        attributes.mapStub = ThrowingStub(defaultError: expectedError)

        #expect(throws: expectedError) {
            try keychain.addItem(with: attributes)
        }
    }


    @Test
    mutating func addItemReturnsConvertedItemWhenConversionSucceeds() throws {
        let expectedObject = randomKeychainDictionary() as CFDictionary
        let attributesDictionary = randomKeychainDictionary() as [CFString: Any]

        let keychainService = MockKeychainServices()
        keychainService.addItemStub = ThrowingStub(defaultResult: .success(expectedObject))
        let keychain = Keychain(keychainService: keychainService)

        let attributes = MockKeychainItemAdditionAttributes<String>()
        attributes.attributesDictionaryStub = Stub(defaultReturnValue: attributesDictionary)

        let convertedValue = randomAlphanumericString()
        attributes.mapStub = ThrowingStub(defaultResult: .success(convertedValue))

        #expect(try keychain.addItem(with: attributes) == convertedValue)
        #expect(keychainService.addItemStub.callArguments as [CFDictionary] == [attributesDictionary] as [CFDictionary])
        #expect(attributes.mapStub.callArguments as? [CFDictionary] == [expectedObject] as [CFDictionary])
    }


    @Test
    mutating func itemsRethrowsErrorWhenKeychainServiceThrowsError() {
        let expectedError = randomError()

        let keychainService = MockKeychainServices()
        keychainService.itemsStub = ThrowingStub(defaultResult: .failure(expectedError))
        let keychain = Keychain(keychainService: keychainService)

        let query = MockKeychainItemQuery<Void>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        query.returnDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        let options = randomKeychainQueryOptions()

        #expect(throws: expectedError) {
            try keychain.items(matching: query, options: options)
        }
    }


    @Test
    mutating func itemsThrowsDataCorruptedErrorWhenKeychainServiceReturnsNil() {
        let keychainService = MockKeychainServices()
        keychainService.itemsStub = ThrowingStub(defaultResult: .success(nil))
        let keychain = Keychain(keychainService: keychainService)

        let query = MockKeychainItemQuery<Void>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        query.returnDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        let options = randomKeychainQueryOptions()

        #expect(throws: KeychainItemMappingError.dataCorrupted) {
            try keychain.items(matching: query, options: options)
        }
    }


    @Test
    mutating func itemsRethrowsErrorWhenConversionThrowsError() {
        let keychainService = MockKeychainServices()
        keychainService.itemsStub = ThrowingStub(defaultResult: .success(randomKeychainDictionary() as CFDictionary))
        let keychain = Keychain(keychainService: keychainService)

        let query = MockKeychainItemQuery<Void>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        query.returnDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        let options = randomKeychainQueryOptions()

        let expectedError = randomError()
        query.mapStub = ThrowingStub(defaultResult: .failure(expectedError))

        #expect(throws: expectedError) {
            try keychain.items(matching: query, options: options)
        }
    }


    @Test(arguments: [false, true])
    mutating func itemsReturnsConvertedItemWhenConversionSucceeds(isLimitNil: Bool) throws {
        let expectedObject = randomKeychainDictionary() as CFDictionary

        // Create some overlap between query dictionary and return dictionary
        var attributesDictionary = randomKeychainDictionary() as [CFString: Any]
        attributesDictionary[kSecMatchLimit] = randomFloat64(in: -10 ... 0)
        attributesDictionary[kSecMatchCaseInsensitive] = randomInt(in: 2 ... .max)

        var returnDictionary = randomKeychainDictionary() as [CFString: Any]
        returnDictionary[attributesDictionary.keys.randomElement()!] = randomAlphanumericString()
        returnDictionary[kSecMatchLimit] = randomFloat64(in: -10 ... 0)
        returnDictionary[kSecMatchCaseInsensitive] = randomInt(in: 2 ... .max)

        let keychainService = MockKeychainServices()
        keychainService.itemsStub = ThrowingStub(defaultResult: .success(expectedObject))
        let keychain = Keychain(keychainService: keychainService)

        let query = MockKeychainItemQuery<UUID>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: attributesDictionary)
        query.returnDictionaryStub = Stub(defaultReturnValue: returnDictionary)

        var options = randomKeychainQueryOptions()
        options.limit = isLimitNil ? nil : randomInt(in: 1 ... .max)

        let convertedValue = randomUUID()
        query.mapStub = ThrowingStub(defaultResult: .success([convertedValue]))

        // Update query attributes to include the correct values
        var expectedDictionary = attributesDictionary.merging(returnDictionary) { $1 }
        expectedDictionary[kSecMatchCaseInsensitive] = options.isCaseInsensitive
        expectedDictionary[kSecMatchLimit] = options.limit ?? kSecMatchLimitAll

        #expect(try keychain.items(matching: query, options: options) == [convertedValue])
        #expect(keychainService.itemsStub.callArguments as [CFDictionary] == [expectedDictionary] as [CFDictionary])
        #expect(query.mapStub.callArguments as? [CFDictionary] == [expectedObject] as [CFDictionary])
    }


    @Test
    mutating func deleteItemsRethrowsErrorWhenKeychainServiceThrowsError() {
        let expectedError = randomError()

        let keychainService = MockKeychainServices()
        keychainService.deleteItemsStub = ThrowingStub(defaultResult: .failure(expectedError))
        let keychain = Keychain(keychainService: keychainService)

        let query = MockKeychainItemQuery<Void>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])
        query.returnDictionaryStub = Stub(defaultReturnValue: randomKeychainDictionary() as [CFString: Any])

        #expect(throws: expectedError) {
            try keychain.deleteItems(matching: query)
        }
    }


    @Test
    mutating func deleteItemsPassesCorrectDictionaryToKeychainServices() throws {
        let keychainService = MockKeychainServices()
        keychainService.deleteItemsStub = ThrowingStub(defaultError: nil)
        let keychain = Keychain(keychainService: keychainService)

        let queryDictionary = randomKeychainDictionary() as [CFString: Any]
        let query = MockKeychainItemQuery<UUID>()
        query.attributesDictionaryStub = Stub(defaultReturnValue: queryDictionary)

        let convertedValue = randomUUID()
        query.mapStub = ThrowingStub(defaultResult: .success([convertedValue]))

        #expect(throws: Never.self) {
            try keychain.deleteItems(matching: query)
        }

        #expect(keychainService.deleteItemsStub.callArguments as [CFDictionary] == [queryDictionary] as [CFDictionary])
    }
}


struct Keychain_QueryOptionsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsValues() {
        let isCaseInsensitive = randomBool()
        let limit = randomOptional(randomInt(in: .min ... .max))
        let options = Keychain.QueryOptions(isCaseInsensitive: isCaseInsensitive, limit: limit)
        #expect(options.isCaseInsensitive == isCaseInsensitive)
        #expect(options.limit == limit)
    }


    @Test(arguments: [false, true])
    mutating func oteamptionDictionaryIsCorrect(isLimitNil: Bool) {
        let isCaseInsensitive = randomBool()
        let limit = isLimitNil ? nil : randomInt(in: .min ... .max)
        let options = Keychain.QueryOptions(isCaseInsensitive: isCaseInsensitive, limit: limit)

        let expected: [CFString: Any] = [
            kSecMatchCaseInsensitive: isCaseInsensitive,
            kSecMatchLimit: limit ?? kSecMatchLimitAll,
        ]

        #expect(options.optionDictionary as CFDictionary == expected as CFDictionary)
    }
}
