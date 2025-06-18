//
//  GenericPasswordIntegrationTests.swift
//  DevKeychainAppTests
//
//  Created by Prachi Gauriar on 6/22/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing


#if !os(macOS)
struct GenericPasswordIntegrationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func addQueryAndDeleteItems() throws {
        let service = randomAlphanumericString(count: 64)
        let accounts = Array(
            Set(count: random(Int.self, in: 3 ... 5)) {
                randomAlphanumericString()
            }
        )
        let keychain = Keychain()
        
        // Delete any existing items with the service
        let serviceQuery = GenericPassword.Query(service: service)
        try keychain.deleteItems(matching: serviceQuery)
        #expect(try keychain.items(matching: serviceQuery).isEmpty)
        
        // Add something for each of our accounts
        for account in accounts {
            let attributes = GenericPassword.AdditionAttributes(
                service: service,
                account: account,
                data: randomData()
            )
            
            let addedItem = try keychain.addItem(with: attributes)
            #expect(addedItem.service == attributes.service)
            #expect(addedItem.account == attributes.account)
            #expect(addedItem.data == attributes.data)
            
            let queryResults = try keychain.items(matching: addedItem.query, options: .init(limit: 1))
            #expect(queryResults == [addedItem])
        }
        
        // Query all items with the service
        let allItems = try keychain.items(matching: serviceQuery)
        #expect(allItems.count == accounts.count)
        
        // Delete everything
        try keychain.deleteItems(matching: serviceQuery)
        #expect(try keychain.items(matching: serviceQuery).isEmpty)
    }
}
#endif
