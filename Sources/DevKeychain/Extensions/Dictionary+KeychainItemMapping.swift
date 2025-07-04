//
//  Dictionary+KeychainItemMapping.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation

extension Dictionary where Key == CFString, Value == Any {
    /// Accesses the value for an attribute of a specified type, throwing errors as appropriate.
    ///
    /// Throws a `KeychainItemMappingError.attributeNotFound(attribute:)` if the attribute is not found. Throws a
    /// `KeychainItemMappingError.attributeTypeMismatch(attribute:type:)` if the attribute has the wrong type.
    ///
    /// - Parameters:
    ///   - attribute: The attribute to find in the dictionary.
    ///   - type: The expected type of the attribute’s value.
    func value<V>(forKeychainAttribute attribute: CFString, type: V.Type) throws -> V {
        guard let rawValue = self[attribute] else {
            throw KeychainItemMappingError.attributeNotFound(attribute as String)
        }

        guard let value = rawValue as? V else {
            throw KeychainItemMappingError.attributeTypeMismatch(attribute: attribute as String, type: V.self)
        }

        return value
    }
}
