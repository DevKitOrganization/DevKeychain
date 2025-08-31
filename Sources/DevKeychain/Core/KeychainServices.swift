//
//  KeychainServices.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation

/// A type that can provides access to Apple’s keychain services API.
///
/// This protocol exists for dependency injection purposes.
protocol KeychainServices: Sendable {
    /// Adds an item with the specified attributes to the keychain.
    ///
    /// - Parameter attributes: The new keychain item’s attributes.
    /// - Returns: The newly added item.
    func addItem(withAttributes attributes: [CFString: Any]) throws -> AnyObject?

    /// Returns keychain items matching the specified query.
    ///
    /// - Parameter query: A dictionary containing attributes of items to match as well as search options.
    func items(matchingQuery query: [CFString: Any]) throws -> AnyObject?

    /// Deletes keychain items matching the specified query.
    ///
    /// - Parameter query: A dictionary containing attributes of items to match as well as search options.
    func deleteItems(matchingQuery attributes: [CFString: Any]) throws
}


/// A standard implementation of the `KeychainServices` protocol.
///
/// This type uses standard Security framework functions like `SecItemAdd(_:_:)`, `SecItemCopyMatching(_:_:)`, and
/// `SecItemDelete(_:)` to implement its behavior.
struct StandardKeychainServices: KeychainServices {
    /// A closure to use to add an item to the keychain.
    ///
    /// By default, this is `SecItemAdd(_:_:)`. It is provided for dependency injection purposes.
    var addItem: @Sendable (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemAdd

    /// A closure to use to copy keychain items matching a query.
    ///
    /// By default, this is `SecItemCopyMatching(_:_:)`. It is provided for dependency injection purposes.
    var copyMatchingItems: @Sendable (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemCopyMatching

    /// A closure to use to delete keychain items matching a query.
    ///
    /// By default, this is `SecItemDelete(_:)`. It is provided for dependency injection purposes.
    var deleteItems: @Sendable (CFDictionary) -> OSStatus = SecItemDelete


    func addItem(withAttributes attributes: [CFString: Any]) throws -> AnyObject? {
        var result: AnyObject?

        let osStatus = addItem(attributes as CFDictionary, &result)
        guard osStatus == errSecSuccess else {
            throw KeychainServicesError(osStatus: osStatus)
        }

        return result
    }


    func items(matchingQuery query: [CFString: Any]) throws -> AnyObject? {
        var result: AnyObject?

        let osStatus = copyMatchingItems(query as CFDictionary, &result)
        switch osStatus {
        case errSecSuccess:
            return result
        case errSecItemNotFound:
            return [] as CFArray
        default:
            throw KeychainServicesError(osStatus: osStatus)
        }
    }


    func deleteItems(matchingQuery query: [CFString: Any]) throws {
        let osStatus = deleteItems(query as CFDictionary)
        if osStatus != errSecSuccess && osStatus != errSecItemNotFound {
            throw KeychainServicesError(osStatus: osStatus)
        }
    }
}
