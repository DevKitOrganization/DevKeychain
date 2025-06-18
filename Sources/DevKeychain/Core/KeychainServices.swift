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
    func addItem(withAttributes attributes: [CFString: Any]) throws -> AnyObject? {
        var result: AnyObject?

        let osStatus = SecItemAdd(attributes as CFDictionary, &result)
        guard osStatus == errSecSuccess else {
            throw KeychainServicesError(osStatus: osStatus)
        }

        return result
    }


    func items(matchingQuery query: [CFString: Any]) throws -> AnyObject? {
        var result: AnyObject?

        let osStatus = SecItemCopyMatching(query as CFDictionary, &result)
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
        let osStatus = SecItemDelete(query as CFDictionary)
        if osStatus != errSecSuccess && osStatus != errSecItemNotFound {
            throw KeychainServicesError(osStatus: osStatus)
        }
    }
}
