//
//  StandardKeychainServicesTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

@preconcurrency import CoreFoundation
import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.KeychainServicesError
@testable import struct DevKeychain.StandardKeychainServices

struct StandardKeychainServicesTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test(arguments: [true, false])
    mutating func addItemSucceedsWhenAddItemClosureReturnsSuccess(hasResult: Bool) throws {
        let expectedResult: AnyObject? = hasResult ? randomKeychainDictionary() as CFDictionary : nil
        let attributes = randomKeychainDictionary() as [CFString: Any]

        nonisolated(unsafe) let addItemStub = Stub<CFDictionary, (OSStatus, AnyObject?)>(
            defaultReturnValue: (errSecSuccess, expectedResult)
        )

        var services = StandardKeychainServices()
        services.addItem = { (attributes, result) in
            let (status, resultValue) = addItemStub(attributes)
            result?.pointee = resultValue
            return status
        }

        let result = try services.addItem(withAttributes: attributes)

        #expect(result === expectedResult)
        #expect(addItemStub.callArguments == [attributes as CFDictionary])
    }


    @Test
    mutating func addItemThrowsKeychainServicesErrorWhenAddItemClosureReturnsFailure() {
        let attributes = randomKeychainDictionary() as [CFString: Any]
        let expectedOSStatus = randomOSStatus(excluding: [errSecSuccess])

        nonisolated(unsafe) let addItemStub = Stub<CFDictionary, (OSStatus, AnyObject?)>(
            defaultReturnValue: (expectedOSStatus, nil)
        )

        var services = StandardKeychainServices()
        services.addItem = { (attributes, result) in
            let (status, resultValue) = addItemStub(attributes)
            result?.pointee = resultValue
            return status
        }

        #expect(throws: KeychainServicesError(osStatus: expectedOSStatus)) {
            try services.addItem(withAttributes: attributes)
        }

        #expect(addItemStub.callArguments == [attributes as CFDictionary])
    }


    @Test(arguments: [true, false])
    mutating func itemsSucceedsWhenCopyMatchingItemsClosureReturnsSuccess(hasResult: Bool) throws {
        let expectedResult: AnyObject? = hasResult ? randomKeychainDictionary() as CFDictionary : nil
        let query = randomKeychainDictionary() as [CFString: Any]

        nonisolated(unsafe) let copyMatchingItemsStub = Stub<CFDictionary, (OSStatus, AnyObject?)>(
            defaultReturnValue: (errSecSuccess, expectedResult)
        )

        var services = StandardKeychainServices()
        services.copyMatchingItems = { (query, result) in
            let (status, resultValue) = copyMatchingItemsStub(query)
            result?.pointee = resultValue
            return status
        }

        let result = try services.items(matchingQuery: query)

        #expect(result === expectedResult)
        #expect(copyMatchingItemsStub.callArguments == [query as CFDictionary])
    }


    @Test
    mutating func itemsReturnsEmptyArrayWhenCopyMatchingItemsClosureReturnsItemNotFound() throws {
        let query = randomKeychainDictionary() as [CFString: Any]

        nonisolated(unsafe) let copyMatchingItemsStub = Stub<CFDictionary, (OSStatus, AnyObject?)>(
            defaultReturnValue: (errSecItemNotFound, nil)
        )

        var services = StandardKeychainServices()
        services.copyMatchingItems = { (query, result) in
            let (status, resultValue) = copyMatchingItemsStub(query)
            result?.pointee = resultValue
            return status
        }

        let result = try #require(try services.items(matchingQuery: query) as? NSArray)

        #expect(CFArrayGetCount(result) == 0)
        #expect(copyMatchingItemsStub.callArguments == [query as CFDictionary])
    }


    @Test
    mutating func itemsThrowsKeychainServicesErrorWhenCopyMatchingItemsClosureReturnsOtherFailure() {
        let query = randomKeychainDictionary() as [CFString: Any]
        let expectedOSStatus = randomOSStatus(excluding: [errSecSuccess, errSecItemNotFound])

        nonisolated(unsafe) let copyMatchingItemsStub = Stub<CFDictionary, (OSStatus, AnyObject?)>(
            defaultReturnValue: (expectedOSStatus, nil)
        )

        var services = StandardKeychainServices()
        services.copyMatchingItems = { (query, result) in
            let (status, resultValue) = copyMatchingItemsStub(query)
            result?.pointee = resultValue
            return status
        }

        #expect(throws: KeychainServicesError(osStatus: expectedOSStatus)) {
            try services.items(matchingQuery: query)
        }

        #expect(copyMatchingItemsStub.callArguments == [query as CFDictionary])
    }


    @Test(arguments: [errSecSuccess, errSecItemNotFound])
    mutating func deleteItemsSucceedsWhenDeleteItemsClosureReturnsSuccessOrItemNotFound(osStatus: OSStatus) throws {
        let query = randomKeychainDictionary() as [CFString: Any]

        nonisolated(unsafe) let deleteItemsStub = Stub<CFDictionary, OSStatus>(
            defaultReturnValue: osStatus
        )

        var services = StandardKeychainServices()
        services.deleteItems = { (query) in
            return deleteItemsStub(query)
        }

        #expect(throws: Never.self) {
            try services.deleteItems(matchingQuery: query)
        }

        #expect(deleteItemsStub.callArguments == [query as CFDictionary])
    }


    @Test
    mutating func deleteItemsThrowsKeychainServicesErrorWhenDeleteItemsClosureReturnsOtherFailure() {
        let query = randomKeychainDictionary() as [CFString: Any]
        let expectedOSStatus = randomOSStatus(excluding: [errSecSuccess, errSecItemNotFound])

        nonisolated(unsafe) let deleteItemsStub = Stub<CFDictionary, OSStatus>(
            defaultReturnValue: expectedOSStatus
        )

        var services = StandardKeychainServices()
        services.deleteItems = { (query) in
            return deleteItemsStub(query)
        }

        #expect(throws: KeychainServicesError(osStatus: expectedOSStatus)) {
            try services.deleteItems(matchingQuery: query)
        }

        #expect(deleteItemsStub.callArguments == [query as CFDictionary])
    }


    private mutating func randomOSStatus(excluding statuses: Set<OSStatus>) -> OSStatus {
        var status: OSStatus
        repeat {
            status = random(Int32.self, in: .min ... .max)
        } while statuses.contains(status)
        return status
    }
}
