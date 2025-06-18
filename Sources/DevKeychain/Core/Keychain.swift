//
//  Keychain.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation


/// An keychain in which secrets can be created, queried, and deleted.
public struct Keychain: Sendable {
    /// The underlying keychain service that the keychain uses.
    ///
    /// This property exists for dependency injection purposes.
    let keychainService: any KeychainServices


    /// Creates a new keychain instance.
    ///
    /// Note that while `Keychain` is a struct, it does not implement value semantics. Each instance uses the OS’s
    /// underyling keychain services, which operate on a shared keychain. As such, adding and deleting items on a
    /// `Keychain` instance will affect other instances.
    public init() {
        self.init(keychainService: StandardKeychainServices())
    }


    /// Creates a new keychain instance with the specified keychain service.
    ///
    /// This initializer exists for dependency injection purposes.
    ///
    /// - Parameter keychainService: underlying Keychain Service that the keychain uses.
    init(keychainService: any KeychainServices) {
        self.keychainService = keychainService
    }


    /// Adds an item with the specified attributes to the keychain.
    ///
    /// - Parameter attributes: Attributes describing the keychain item to add.
    /// - Returns: The added item.
    @discardableResult
    public func addItem<AdditionAttributes>(with attributes: AdditionAttributes) throws -> AdditionAttributes.Item
    where AdditionAttributes: KeychainItemAdditionAttributes {
        guard let item = try keychainService.addItem(withAttributes: attributes.attributesDictionary) else {
            throw KeychainItemMappingError.dataCorrupted
        }

        return try attributes.mapAddedItem(item)
    }


    /// Returns items in the keychain that match the specified query.
    ///
    /// - Parameters:
    ///   - query: A query describing the keychain items to return.
    ///   - options: Options that affect how the query is performed.
    public func items<Query>(matching query: Query, options: QueryOptions = .init()) throws -> [Query.Item]
    where Query: KeychainItemQuery {
        var queryDictionary = query.attributesDictionary
        queryDictionary.merge(query.returnDictionary) { $1 }
        queryDictionary.merge(options.optionDictionary) { $1 }

        guard let items = try keychainService.items(matchingQuery: queryDictionary) else {
            throw KeychainItemMappingError.dataCorrupted
        }

        return try query.mapMatchingItems(items)
    }


    /// Deletes items in the keychain that match the specified query.
    ///
    /// - Parameter query: A query describing the keychain items to delete.
    public func deleteItems(matching query: some KeychainItemQuery) throws {
        try keychainService.deleteItems(matchingQuery: query.attributesDictionary)
    }
}


extension Keychain {
    /// Options that affect how a keychain query is performed.
    public struct QueryOptions: Sendable {
        /// Whether queries should ignore string case when comparing strings.
        public var isCaseInsensitive: Bool
        
        /// The maximum number of items that queries should return.
        ///
        /// `nil` indicates no maximum. `nil` by default.
        public var limit: Int?

        
        /// Creates new query options.
        ///
        /// - Parameters:
        ///   - isCaseInsensitive: Whether the query should ignore string case when comparing strings. `false` by
        ///     default.
        ///   - limit: The maximum number of items that queries should return. `nil` indicates no maximum. `nil` by
        ///     default.
        public init(isCaseInsensitive: Bool = false, limit: Int? = nil) {
            self.isCaseInsensitive = isCaseInsensitive
            self.limit = limit
        }


        /// A dictionary-representation of the options to pass to the keychain services API.
        var optionDictionary: [CFString : Any] {
            return [
                kSecMatchCaseInsensitive: isCaseInsensitive,
                kSecMatchLimit: limit ?? kSecMatchLimitAll
            ]
        }
    }
}
