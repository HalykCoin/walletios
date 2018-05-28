// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RefreshType {
    case balance
}

class WalletSession {
    let account: Account
    let web3: Web3Swift
    let config: Config
    var balance: Balance?
    let chainState: ChainState

    var balanceViewModel: BalanceBaseViewModel?

    init(
        account: Account,
        config: Config
    ) {
        self.account = account
        self.config = config
        self.web3 = Web3Swift(url: config.rpcURL)
        self.chainState = ChainState(config: config)
        self.web3.start()
        self.chainState.start()
        self.balanceViewModel = nil
        self.balance = nil
    }

    func refresh(_ type: RefreshType) {

    }

    func stop() {
        chainState.stop()
    }
}
