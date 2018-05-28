// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

struct Account {
    let address: Address
    let id: String

    init(address: Address) {
        self.init(address: address, id: "")
    }
    
    init(address: Address, id: String) {
        self.address = address
        self.id = id
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address.address == rhs.address.address
    }
}
