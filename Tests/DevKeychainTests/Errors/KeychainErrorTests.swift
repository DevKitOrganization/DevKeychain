//
//  KeychainServicesErrorTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

import DevTesting
import Foundation
import Testing

@testable import struct DevKeychain.KeychainServicesError

struct KeychainServicesErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let osStatus = random(OSStatus.self, in: .min ... .max)
        let error = KeychainServicesError(osStatus: osStatus)
        #expect(error.osStatus == osStatus)
    }


    @Test
    mutating func descriptionReturnsCorrectValueWhenStatusIsKnown() {
        let osStatus = randomElement(in: [errSecSuccess, errSecItemNotFound, errSecBadReq])!

        let error = KeychainServicesError(osStatus: osStatus)
        #expect(error.description == SecCopyErrorMessageString(osStatus, nil) as? String)
    }
}
