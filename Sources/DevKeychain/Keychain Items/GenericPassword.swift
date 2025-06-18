//
//  GenericPassword.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation


/// A generic password keychain item.
public struct GenericPassword: Hashable, Sendable {
    /// The item’s service.
    public let service: String

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
        return .init(service: service, account: account)
    }
}


extension GenericPassword {
    /// Creates a new generic password with the specified attributes.
    ///
    /// - Parameter attributes: A dictionary of attributes from the keychain services API.
    init(attributes: [CFString : Any]) throws {
        self.init(
            service: try attributes.value(forKeychainAttribute: kSecAttrService, type: String.self),
            account: try attributes.value(forKeychainAttribute: kSecAttrAccount, type: String.self),
            data: try attributes.value(forKeychainAttribute: kSecValueData, type: Data.self)
        )
    }
}


extension GenericPassword {
    /// Attributes for adding a new generic password to the keychain.
    public struct AdditionAttributes: Hashable, KeychainItemAdditionAttributes {
        /// The new item’s service.
        public var service: String

        /// The new item’s account.
        public var account: String

        /// The new item’s secret data.
        public var data: Data


        /// Creates generic password addition attributes with secret data.
        ///
        /// - Parameters:
        ///   - service: The new item’s service.
        ///   - account: The new item’s acocunt.
        ///   - data: The new item’s secret data.
        public init(service: String, account: String, data: Data) {
            self.service = service
            self.account = account
            self.data = data
        }


        /// Creates generic password addition attributes with a password.
        ///
        /// Returns `nil` if `password` cannot be encoded using `encoding`.
        ///
        /// - Parameters:
        ///   - service: The new item’s service.
        ///   - account: The new item’s acocunt.
        ///   - password: The new item’s secret data as a string.
        ///   - encoding: The string encoding to use when converting `password` to `Data`. Defaults to `.utf8`.
        public init?(service: String, account: String, password: String, encoding: String.Encoding = .utf8) {
            guard let data = password.data(using: encoding) else {
                return nil
            }

            self.init(service: service, account: account, data: data)
        }


        public var attributesDictionary: [CFString : Any] {
            return [
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecClass: kSecClassGenericPassword,
                kSecReturnAttributes: true,
                kSecReturnData: true,
                kSecUseDataProtectionKeychain: true,
                kSecValueData: data,
            ]
        }


        public func mapAddedItem(_ rawItem: AnyObject) throws -> GenericPassword {
            guard let attributes = rawItem as? [CFString: Any] else {
                throw KeychainItemMappingError.dataCorrupted
            }

            return try .init(attributes: attributes)
        }
    }
}


extension GenericPassword {
    /// A query for finding generic passwords in the keychain.
    public struct Query: Hashable, KeychainItemQuery {
        /// The service that matching items must have.
        ///
        /// If `nil`, matching items can have any service. `nil` by default.
        public var service: String?

        /// The account that matching items must have.
        ///
        /// If `nil`, matching items can have any account. `nil` by default.
        public var account: String?

        
        /// Creates a new generic password query.
        ///
        /// - Parameters:
        ///   - service: The service that matching items must have. If `nil`, matching items can have any service.
        ///     `nil` by default.
        ///   - account: The account that matching items must have. If `nil`, matching items can have any account.
        ///     `nil` by default.
        public init(service: String? = nil, account: String? = nil) {
            self.service = service
            self.account = account
        }


        public var attributesDictionary: [CFString : Any] {
            var dictionary: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecUseDataProtectionKeychain: true,
            ]

            if let account = account {
                dictionary[kSecAttrAccount] = account
            }

            if let service = service {
                dictionary[kSecAttrService] = service
            }

            return dictionary
        }


        public var returnDictionary: [CFString : Any] {
            return [
                kSecReturnAttributes: true,
                kSecReturnData: true,
            ]
        }


        public func mapMatchingItems(_ rawItems: AnyObject) throws -> [GenericPassword] {
            let attributesArray: [[CFString : Any]]

            if let singleItem = rawItems as? [CFString : Any] {
                attributesArray = [singleItem]
            } else if let array = rawItems as? [[CFString : Any]] {
                attributesArray = array
            } else {
                throw KeychainItemMappingError.dataCorrupted
            }

            return try attributesArray.map(GenericPassword.init(attributes:))
        }
    }
}
