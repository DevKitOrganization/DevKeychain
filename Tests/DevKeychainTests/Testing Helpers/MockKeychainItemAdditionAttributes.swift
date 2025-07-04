//
//  MockKeychainItemAdditionAttributes.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import DevKeychain
import DevTesting
import Foundation

final class MockKeychainItemAdditionAttributes<Item>: KeychainItemAdditionAttributes where Item: Sendable {
    nonisolated(unsafe) var attributesDictionaryStub: Stub<Void, [CFString: Any]>!
    nonisolated(unsafe) var mapStub: ThrowingStub<AnyObject, Item, any Error>!


    var attributesDictionary: [CFString: Any] {
        return attributesDictionaryStub()
    }


    func mapAddedItem(_ rawItem: AnyObject) throws -> Item {
        return try mapStub(rawItem)
    }
}
