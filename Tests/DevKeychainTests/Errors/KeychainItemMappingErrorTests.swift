//
//  KeychainItemMappingErrorTests.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/19/25.
//

@testable import enum DevKeychain.KeychainItemMappingError
import DevTesting
import Foundation
import Testing


struct KeychainItemMappingErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func equalChecks() {
        let attribute1 = randomAlphanumericString()
        let attribute2 = randomAlphanumericString()
        let type1 = String.self
        let type2 = Int.self

        let dataCorrupted = KeychainItemMappingError.dataCorrupted
        let notFound1 = KeychainItemMappingError.attributeNotFound(attribute1)
        let notFound2 = KeychainItemMappingError.attributeNotFound(attribute2)
        let typeMismatch1 = KeychainItemMappingError.attributeTypeMismatch(attribute: attribute1, type: type1)
        let typeMismatch2 = KeychainItemMappingError.attributeTypeMismatch(attribute: attribute2, type: type2)

        #expect(dataCorrupted == dataCorrupted)
        #expect(dataCorrupted != notFound1)
        #expect(dataCorrupted != typeMismatch1)

        #expect(notFound1 == notFound1)
        #expect(notFound2 == notFound2)
        #expect(notFound1 != notFound2)
        #expect(notFound2 != notFound1)
        #expect(notFound1 != dataCorrupted)
        #expect(notFound1 != typeMismatch1)

        #expect(typeMismatch1 == typeMismatch1)
        #expect(typeMismatch2 == typeMismatch2)
        #expect(typeMismatch1 != typeMismatch2)
        #expect(typeMismatch2 != typeMismatch1)
        #expect(typeMismatch1 != dataCorrupted)
        #expect(typeMismatch1 != notFound1)
    }
}
