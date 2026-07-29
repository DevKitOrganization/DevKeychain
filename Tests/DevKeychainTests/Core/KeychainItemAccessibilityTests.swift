//
//  KeychainItemAccessibilityTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 7/28/26.
//

import DevTesting
import Foundation
import Security
import Testing

@testable import DevKeychain

struct KeychainItemAccessibilityTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initWithStringReturnsNilForUnknownString() {
        // set up
        let unknownString = randomAlphanumericString()

        // exercise / expect
        #expect(KeychainItemAccessibility(string: unknownString) == nil)
    }


    @Test
    func initWithStringSetsCorrectCaseForEachKnownValue() {
        // set up
        let cases: [(CFString, KeychainItemAccessibility)] = [
            (kSecAttrAccessibleAfterFirstUnlock, .afterFirstUnlock),
            (kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, .afterFirstUnlockThisDeviceOnly),
            (kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .whenPasscodeSetThisDeviceOnly),
            (kSecAttrAccessibleWhenUnlocked, .whenUnlocked),
            (kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .whenUnlockedThisDeviceOnly),
        ]

        // exercise / expect
        for (string, expectedCase) in cases {
            #expect(KeychainItemAccessibility(string: string as String) == expectedCase)
        }
    }


    @Test
    func attributeValueReturnsCorrectValueForEachCase() {
        // set up
        let cases: [(KeychainItemAccessibility, CFString)] = [
            (.afterFirstUnlock, kSecAttrAccessibleAfterFirstUnlock),
            (.afterFirstUnlockThisDeviceOnly, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            (.whenPasscodeSetThisDeviceOnly, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly),
            (.whenUnlocked, kSecAttrAccessibleWhenUnlocked),
            (.whenUnlockedThisDeviceOnly, kSecAttrAccessibleWhenUnlockedThisDeviceOnly),
        ]

        // exercise / expect
        for (accessibility, expectedValue) in cases {
            #expect(accessibility.attributeValue as! CFString == expectedValue)
        }
    }
}
