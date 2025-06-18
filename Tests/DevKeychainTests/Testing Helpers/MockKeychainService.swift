//
//  MockKeychainServices.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

@testable import protocol DevKeychain.KeychainServices
import DevTesting
import Foundation


final class MockKeychainServices: KeychainServices {
    nonisolated(unsafe)
    var addItemStub: ThrowingStub<[CFString: Any], AnyObject?, any Error>!

    nonisolated(unsafe)
    var itemsStub: ThrowingStub<[CFString: Any], AnyObject?, any Error>!

    nonisolated(unsafe)
    var deleteItemsStub: ThrowingStub<[CFString: Any], Void, any Error>!


    func addItem(withAttributes attributes: [CFString : Any]) throws -> AnyObject? {
        return try addItemStub(attributes)
    }


    func items(matchingQuery query: [CFString : Any]) throws -> AnyObject? {
        return try itemsStub(query)
    }


    func deleteItems(matchingQuery attributes: [CFString : Any]) throws {
        return try deleteItemsStub(attributes)
    }
}
