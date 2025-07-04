//
//  KeychainServicesError.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import Foundation

/// An error from the keychain services API.
struct KeychainServicesError: CustomStringConvertible, Error, Hashable {
    /// The underlying `OSStatus` that describes the error.
    let osStatus: OSStatus


    var description: String {
        return SecCopyErrorMessageString(osStatus, nil)
            .map { $0 as String } ?? "Unknown Keychain error: \(osStatus)"
    }
}
