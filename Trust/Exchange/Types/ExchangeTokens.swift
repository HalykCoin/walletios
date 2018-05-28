// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeTokens {
    static func get(for server: RPCServer) -> [ExchangeToken] {
        return [
            ExchangeToken(name: "Halykcoin", address: Address(address: "427D4pa2HEHPbdSPuhadu4cJtkXFErAuFAa6f2s8v2ZW37WaD9vNMAgNjVNwkHcvdvLGTz84631ybDcyYjRWBMZFBZfK6AN"), symbol: "HLC", image: R.image.import_options(), decimals: 18),
        ]
    }
}
