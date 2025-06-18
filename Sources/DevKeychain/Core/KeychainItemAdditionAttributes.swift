//
//  KeychainItemAdditionAttributes.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import Foundation


/// A type that describes the attributes of an item to add to the keychain.
public protocol KeychainItemAdditionAttributes<Item>: Sendable {
    /// The type of item that the attributes describe.
    associatedtype Item: Sendable
    
    /// A dictionary-representation of the new item to pass to the keychain services API.
    var attributesDictionary: [CFString: Any] { get }
    
    /// Maps the raw return value from the keychain services API into the instance’s `Item` type.
    ///
    /// - Parameter rawItem: An object returned by the keychain services API that represents the added item.
    /// - Returns: A new `Item` instance created using information in `rawItem`.
    func mapAddedItem(_ rawItem: AnyObject) throws -> Item
}
