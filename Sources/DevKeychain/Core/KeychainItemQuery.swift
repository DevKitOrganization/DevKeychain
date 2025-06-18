//
//  KeychainItemQuery.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import Foundation


/// A type that describes a query for specific kinds of items in the keychain.
public protocol KeychainItemQuery<Item>: Sendable {
    /// The type of item that the query returns.
    associatedtype Item: Sendable

    /// A dictionary of the item attributes to match against when querying keychain services API.
    ///
    /// This dictionary is used to both find and delete items. It should not contain search attribute keys, like
    /// `kSecMatchCaseInsensitive` or `kSecMatchLimit`, or item return result keys like `kSecReturnAttributes` or
    /// `kSecReturnData`.
    var attributesDictionary: [CFString: Any] { get }

    /// A dictionary describing how query results should be returned from the keychain services API.
    ///
    /// This dictionary is combined with ``attributesDictionary`` when finding items. It is not used to delete items. It
    /// should only contain item return result keys like `kSecReturnAttributes` or `kSecReturnData`.
    var returnDictionary: [CFString: Any] { get }

    /// Maps the raw return value from the keychain services API into an array of the instance’s `Item` type.
    ///
    /// - Parameter rawItems: An object returned by the keychain services API that represents the matching items.
    /// - Returns: An array of `Item` instances created using information in `rawItems`.
    func mapMatchingItems(_ rawItems: AnyObject) throws -> [Item]
}
