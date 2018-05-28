// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit

protocol BalanceCoordinatorDelegate: class {
    func didUpdate(viewModel: BalanceViewModel)
}

class BalanceCoordinator {

    let exchangeRateCoordinator = ExchangeRateCoordinator()
    let session: WalletSession

    weak var delegate: BalanceCoordinatorDelegate?

    var balance: Balance? {
        didSet { update() }
    }
    var currencyRate: CurrencyRate? {
        didSet { update() }
    }

    var viewModel: BalanceViewModel {
        return BalanceViewModel(
            balance: balance,
            rate: currencyRate
        )
    }

    init(session: WalletSession) {
        self.session = session
    }

    func start() {
        exchangeRateCoordinator.delegate = self
        exchangeRateCoordinator.start()
    }

    func fetch() {
        exchangeRateCoordinator.fetch()
    }

    func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
}

extension BalanceCoordinator: ExchangeRateCoordinatorDelegate {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator) {
        currencyRate = rate
    }
}
