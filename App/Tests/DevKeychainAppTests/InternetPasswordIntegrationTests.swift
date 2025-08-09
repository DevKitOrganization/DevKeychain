//
//  InternetPasswordIntegrationTests.swift
//  DevKeychainAppTests
//
//  Created by Prachi Gauriar on 6/22/25.
//

import DevKeychain
import DevTesting
import Foundation
import Testing

#if !os(macOS)
struct InternetPasswordIntegrationTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func addQueryAndDeleteItems() throws {
        let server = randomAlphanumericString(count: 64)
        let accounts = Array(
            Set(count: randomInt(in: 3 ... 5)) {
                randomAlphanumericString()
            }
        )
        let keychain = Keychain()

        // Delete any existing items with the server
        let serverQuery = InternetPassword.Query(server: server)
        try keychain.deleteItems(matching: serverQuery)
        #expect(try keychain.items(matching: serverQuery).isEmpty)

        // Add something for each of our accounts
        for account in accounts {
            let attributes = InternetPassword.AdditionAttributes(
                server: server,
                account: account,
                data: randomData()
            )

            let addedItem = try keychain.addItem(with: attributes)
            #expect(addedItem.server == attributes.server)
            #expect(addedItem.account == attributes.account)
            #expect(addedItem.data == attributes.data)

            let queryResults = try keychain.items(matching: addedItem.query, options: .init(limit: 1))
            #expect(queryResults == [addedItem])
        }

        // Query all items with the server
        let allItems = try keychain.items(matching: serverQuery)
        #expect(allItems.count == accounts.count)

        // Delete everything
        try keychain.deleteItems(matching: serverQuery)
        #expect(try keychain.items(matching: serverQuery).isEmpty)
    }
}
#endif
