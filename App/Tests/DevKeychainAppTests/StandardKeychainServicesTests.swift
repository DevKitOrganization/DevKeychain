//
//  StandardKeychainServicesTests.swift
//  DevKeychainAppTests
//
//  Created by Prachi Gauriar on 6/22/25.
//

import DevTesting
import Foundation
import Testing

@testable import DevKeychain

struct StandardKeychainServicesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func addQueryAndDeleteItemsSucceeds() throws {
        let service = randomAlphanumericString(count: 64)
        let accounts = Array(
            Set(count: random(Int.self, in: 3 ... 5)) {
                randomAlphanumericString()
            }
        )
        let keychainServices = StandardKeychainServices()

        // Delete any existing items with the service
        let serviceQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnAttributes: true,
        ]

        try keychainServices.deleteItems(matchingQuery: serviceQuery)
        #expect((try keychainServices.items(matchingQuery: serviceQuery) as? [Any])?.isEmpty == true)

        for account in accounts {
            var attributes = serviceQuery
            attributes[kSecAttrAccount] = account
            attributes[kSecValueData] = randomData()
            let newItem = try keychainServices.addItem(withAttributes: attributes)
            #expect(newItem is [CFString: Any])
        }

        var allItemsQuery = serviceQuery
        allItemsQuery[kSecMatchLimit] = kSecMatchLimitAll
        let allItems = try keychainServices.items(matchingQuery: allItemsQuery)
        #expect((allItems as? [Any])?.count == accounts.count)

        try keychainServices.deleteItems(matchingQuery: serviceQuery)
        #expect((try keychainServices.items(matchingQuery: serviceQuery) as? [Any])?.isEmpty == true)
    }


    @Test
    func addItemThrowsErrorWhenSecItemAddThrows() {
        let keychainServices = StandardKeychainServices()

        #expect(throws: KeychainServicesError(osStatus: errSecParam)) {
            _ = try keychainServices.addItem(withAttributes: [:])
        }
    }


    @Test
    func itemsThrowsErrorWhenSecItemCopyMatchingReturnsNotSuccess() {
        let keychainServices = StandardKeychainServices()

        #expect(throws: KeychainServicesError(osStatus: errSecParam)) {
            _ = try keychainServices.items(matchingQuery: [:])
        }
    }


    @Test
    mutating func itemsReturnsEmptyArrayWhenSecItemCopyMatchingReturnsNotFound() throws {
        let keychainServices = StandardKeychainServices()

        let object = try keychainServices.items(
            matchingQuery: [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: randomAlphanumericString(count: 32),
            ]
        )
        let items = try #require(object as? [Any])
        #expect(items.isEmpty)
    }


    @Test
    func deleteItemsThrowsErrorWhenSecItemDeleteReturnsNotSuccess() {
        let keychainServices = StandardKeychainServices()

        #expect(throws: KeychainServicesError(osStatus: errSecParam)) {
            _ = try keychainServices.deleteItems(matchingQuery: [:])
        }
    }


    @Test
    mutating func deleteItemsDoesNotThrowWhenSecItemDeleteReturnsNotFound() throws {
        let keychainServices = StandardKeychainServices()

        #expect(throws: Never.self) {
            try keychainServices.deleteItems(
                matchingQuery: [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: randomAlphanumericString(count: 32),
                ]
            )
        }
    }
}
