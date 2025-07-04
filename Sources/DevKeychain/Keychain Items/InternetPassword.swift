//
//  InternetPassword.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation

/// An internet password keychain item.
public struct InternetPassword: Hashable, Sendable {
    /// The item’s server.
    public let server: String

    /// The item’s account.
    public let account: String

    /// The item’s secret data.
    ///
    /// If this data is textual, you can use ``password(using:)`` to easily access it.
    public let data: Data


    /// Returns the item’s secret data as a string.
    ///
    /// - Parameter encoding: The data’s string encoding. Defaults to `.utf8`.
    /// - Returns: The item’s secret data as a string, or `nil` if it couldn’t be converted to a string.
    public func password(using encoding: String.Encoding = .utf8) -> String? {
        return String(data: data, encoding: encoding)
    }


    /// Returns a query that will match this item exactly.
    public var query: Query {
        return .init(server: server, account: account)
    }
}


extension InternetPassword {
    /// Creates a new internet password with the specified attributes.
    ///
    /// - Parameter attributes: A dictionary of attributes from the keychain services API.
    init(attributes: [CFString: Any]) throws {
        self.init(
            server: try attributes.value(forKeychainAttribute: kSecAttrServer, type: String.self),
            account: try attributes.value(forKeychainAttribute: kSecAttrAccount, type: String.self),
            data: try attributes.value(forKeychainAttribute: kSecValueData, type: Data.self)
        )
    }
}


extension InternetPassword {
    /// Attributes for adding a new internet password to the keychain.
    public struct AdditionAttributes: KeychainItemAdditionAttributes {
        /// The new item’s server.
        public var server: String

        /// The new item’s account.
        public var account: String

        /// The new item’s secret data.
        public var data: Data


        /// Creates internet password addition attributes with secret data.
        ///
        /// - Parameters:
        ///   - server: The new item’s server.
        ///   - account: The new item’s acocunt.
        ///   - data: The new item’s secret data.
        public init(server: String, account: String, data: Data) {
            self.server = server
            self.account = account
            self.data = data
        }


        /// Creates internet password addition attributes with a password.
        ///
        /// Returns `nil` if `password` cannot be encoded using `encoding`.
        ///
        /// - Parameters:
        ///   - server: The new item’s server.
        ///   - account: The new item’s acocunt.
        ///   - password: The new item’s secret data as a string.
        ///   - encoding: The string encoding to use when converting `password` to `Data`. Defaults to `.utf8`.
        public init?(server: String, account: String, password: String, encoding: String.Encoding = .utf8) {
            guard let data = password.data(using: encoding) else {
                return nil
            }

            self.init(server: server, account: account, data: data)
        }


        public var attributesDictionary: [CFString: Any] {
            return [
                kSecAttrAccount: account,
                kSecAttrServer: server,
                kSecClass: kSecClassInternetPassword,
                kSecReturnAttributes: true,
                kSecReturnData: true,
                kSecUseDataProtectionKeychain: true,
                kSecValueData: data,
            ]
        }


        public func mapAddedItem(_ rawItem: AnyObject) throws -> InternetPassword {
            guard let attributes = rawItem as? [CFString: Any] else {
                throw KeychainItemMappingError.dataCorrupted
            }

            return try .init(attributes: attributes)
        }
    }
}


extension InternetPassword {
    /// A query for finding internet passwords in the keychain.
    public struct Query: KeychainItemQuery {
        /// The server that matching items must have.
        ///
        /// If `nil`, matching items can have any server. `nil` by default.
        public var server: String?

        /// The account that matching items must have.
        ///
        /// If `nil`, matching items can have any account. `nil` by default.
        public var account: String?


        /// Creates a new internet password query.
        ///
        /// - Parameters:
        ///   - server: The server that matching items must have. If `nil`, matching items can have any server.
        ///     `nil` by default.
        ///   - account: The account that matching items must have. If `nil`, matching items can have any account.
        ///     `nil` by default.
        public init(server: String? = nil, account: String? = nil) {
            self.server = server
            self.account = account
        }


        public var attributesDictionary: [CFString: Any] {
            var dictionary: [CFString: Any] = [
                kSecClass: kSecClassInternetPassword,
                kSecUseDataProtectionKeychain: true,
            ]

            if let account = account {
                dictionary[kSecAttrAccount] = account
            }

            if let server = server {
                dictionary[kSecAttrServer] = server
            }

            return dictionary
        }


        public var returnDictionary: [CFString: Any] {
            return [
                kSecReturnAttributes: true,
                kSecReturnData: true,
            ]
        }


        public func mapMatchingItems(_ rawItems: AnyObject) throws -> [InternetPassword] {
            let attributesArray: [[CFString: Any]]

            if let singleItem = rawItems as? [CFString: Any] {
                attributesArray = [singleItem]
            } else if let array = rawItems as? [[CFString: Any]] {
                attributesArray = array
            } else {
                throw KeychainItemMappingError.dataCorrupted
            }

            return try attributesArray.map(InternetPassword.init(attributes:))
        }
    }
}
