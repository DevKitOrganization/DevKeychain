//
//  RandomValueGenerating+DevKeychain.swift
//  DevKeychain
//
//  Created by Prachi Gauriar on 6/18/25.
//

import DevKeychain
import DevTesting
import Foundation


extension RandomValueGenerating {
    mutating func randomError() -> MockError {
        return randomCase(of: MockError.self)!
    }


    mutating func randomKeychainDictionary() -> [String: String] {
        return Dictionary(count: random(Int.self, in: 3 ... 5)) {
            (randomAlphanumericString(), randomAlphanumericString())
        }
    }


    mutating func randomKeychainQueryOptions() -> Keychain.QueryOptions {
        return .init(
            isCaseInsensitive: randomBool(),
            limit: randomOptional(random(Int.self, in: 1 ... 10))
        )
    }
}
