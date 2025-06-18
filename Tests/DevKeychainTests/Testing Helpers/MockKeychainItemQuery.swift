//
//  MockKeychainItemQuery.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import DevKeychain
import DevTesting
import Foundation


final class MockKeychainItemQuery<Item>: KeychainItemQuery where Item: Sendable {
    nonisolated(unsafe)
    var attributesDictionaryStub: Stub<Void, [CFString: Any]>!

    nonisolated(unsafe)
    var returnDictionaryStub: Stub<Void, [CFString: Any]>!

    nonisolated(unsafe)
    var mapStub: ThrowingStub<AnyObject, [Item], any Error>!


    var attributesDictionary: [CFString : Any] {
        return attributesDictionaryStub()
    }


    var returnDictionary: [CFString : Any] {
        return returnDictionaryStub()
    }


    func mapMatchingItems(_ rawItems: AnyObject) throws -> [Item] {
        return try mapStub(rawItems)
    }
}
