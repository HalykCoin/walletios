// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

struct Balance: BalanceProtocol {

    let value: BigInt
    let balance: BigInt
    let unlocked_balance: BigInt

    init(value: BigInt, balance: BigInt, unlocked_balance: BigInt) {
        self.value = value
        self.balance = balance
        self.unlocked_balance = unlocked_balance
    }
    
    init(balance: BigInt, unlocked_balance: BigInt) {
        self.init(value: BigInt(), balance: balance, unlocked_balance: unlocked_balance)
    }
    
    init(value: BigInt) {
        self.init(value: value, balance: 0, unlocked_balance: 0)
    }

    var isZero: Bool {
        return balance == 0
    }

    var amount: String {
        return EtherNumberFormatter.short.string(from: value)
    }

    var amountFull: String {
        return amount
    }

    var balanceString: String {
        return HalykNumberFormatter.short.string(from: balance)
    }

    var availableBalanceString: String {
        return HalykNumberFormatter.short.string(from: unlocked_balance)
    }
}

extension Balance {
    static func from(json: [String: AnyObject]) -> Balance? {
        
        let balance = json["balance"] as? Int ?? 0
        let unlocked_balance = json["unlocked_balance"] as? Int ?? 0
        
        return Balance(
            balance: BigInt(balance),
            unlocked_balance: BigInt(unlocked_balance)
        )
    }
}
