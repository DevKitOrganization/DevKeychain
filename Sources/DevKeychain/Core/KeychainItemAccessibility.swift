//
//  KeychainItemAccessibility.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 7/28/26.
//

import Foundation
import Security

/// The conditions under which a keychain item can be accessed.
///
/// Each case corresponds to a `kSecAttrAccessible*` constant from the Security framework. When adding a keychain item,
/// set its accessibility to control when the item can be read.
public enum KeychainItemAccessibility: String, CaseIterable, Codable, Sendable {
    /// The item is accessible after the device has been unlocked once following a restart.
    ///
    /// This is the recommended default for most items. Items with this accessibility are backed up to iCloud and
    /// transferred to new devices.
    case afterFirstUnlock

    /// The item is accessible after the device has been unlocked once following a restart, but is not backed up or
    /// transferred to other devices.
    case afterFirstUnlockThisDeviceOnly

    /// The item is only accessible when the device has a passcode set.
    ///
    /// Items with this accessibility are not backed up or transferred to other devices. If the device passcode is
    /// removed, matching items are deleted from the keychain.
    case whenPasscodeSetThisDeviceOnly

    /// The item is only accessible while the device is unlocked.
    ///
    /// Items with this accessibility are backed up to iCloud and transferred to new devices.
    case whenUnlocked

    /// The item is only accessible while the device is unlocked, but is not backed up or transferred to other devices.
    case whenUnlockedThisDeviceOnly


    /// Creates an instance from a Security framework accessibility string.
    ///
    /// - Parameter string: A Security framework accessibility string, such as `kSecAttrAccessibleWhenUnlocked`.
    /// - Returns: An instance corresponding to `string`, or `nil` if no case matches.
    public init?(string: String) {
        switch string as CFString {
        case kSecAttrAccessibleAfterFirstUnlock:
            self = .afterFirstUnlock
        case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
            self = .afterFirstUnlockThisDeviceOnly
        case kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly:
            self = .whenPasscodeSetThisDeviceOnly
        case kSecAttrAccessibleWhenUnlocked:
            self = .whenUnlocked
        case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
            self = .whenUnlockedThisDeviceOnly
        default:
            return nil
        }
    }


    /// The value’s corresponding Security framework accessibility constant.
    var attributeValue: Any {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}
