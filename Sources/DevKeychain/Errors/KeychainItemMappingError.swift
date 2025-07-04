//
//  KeychainItemMappingError.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation

/// An error that can occur while mapping a keychain services API return value to a keychain item.
enum KeychainItemMappingError: Error, Equatable {
    /// Indicates that the data being mapped is corrupted or otherwise invalid.
    case dataCorrupted

    /// Indicates that an attribute needed for mapping was not found.
    case attributeNotFound(String)

    /// Indicates that an attribute needed for mapping had an incorrect type.
    case attributeTypeMismatch(attribute: String, type: Any.Type)


    static func == (lhs: KeychainItemMappingError, rhs: KeychainItemMappingError) -> Bool {
        switch (lhs, rhs) {
        case (.dataCorrupted, .dataCorrupted):
            return true
        case (.attributeNotFound(let lhsAttribute), .attributeNotFound(let rhsAttribute)):
            return lhsAttribute == rhsAttribute
        case (
            .attributeTypeMismatch(let lhsAttribute, let lhsType),
            .attributeTypeMismatch(let rhsAttribute, let rhsType)
        ):
            return lhsAttribute == rhsAttribute && lhsType == rhsType
        default:
            return false
        }
    }
}
