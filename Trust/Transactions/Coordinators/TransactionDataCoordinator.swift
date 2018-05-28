// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import JSONRPCKit
import APIKit
import RealmSwift
import Result
import Moya

enum TransactionError: Error {
    case failedToFetch
}

protocol TransactionDataCoordinatorDelegate: class {
    func didUpdate(result: Result<[TransactionHalyk], TransactionError>)
}

class TransactionDataCoordinator {

    let storage: TransactionsStorage
    let session: WalletSession
    let config = Config()
    var viewModel: TransactionsViewModel {
        return .init(transactions:[])
    }
    var timer: Timer?
    var updateTransactionsTimer: Timer?

    weak var delegate: TransactionDataCoordinatorDelegate?

    private let trustProvider = MoyaProvider<TrustService>()

    init(
        session: WalletSession,
        storage: TransactionsStorage
    ) {
        self.session = session
        self.storage = storage
    }

    func start() {
        //todo: return back transactions timer
//        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchPending), userInfo: nil, repeats: true)
//        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(fetchTransactions), userInfo: nil, repeats: true)
    }

    func fetch() {
        session.refresh(.balance)
        fetchTransactions()
    }

    @objc func fetchTransactions() {
        let id = session.account.id
        let request = TransactionsRequestHalyk(id: id)
        Session.send(request) { result in
            switch result {
            case .success(let transactions):
                self.delegate?.didUpdate(result: .success(transactions))
            case .failure(let error):
                self.handleError(error: error)
            }
        }
        
//        let startBlock: Int = {
//            guard let transaction = storage.objects.first, storage.objects.count >= 30 else {
//                return 1
//            }
//            return transaction.blockNumber - 2000
//        }()
//        trustProvider.request(.getTransactions(address: session.account.address.address, startBlock: startBlock)) { result in
//            switch result {
//            case .success(let response):
//                do {
//                    let transactions = try response.map(ArrayResponse<RawTransaction>.self).docs
//                    let chainID = self.config.chainID
//                    let transactions2: [Transaction] = transactions.map { .from(
//                        chainID: chainID,
//                        owner: self.session.account.address,
//                        transaction: $0
//                        )
//                    }
//                    self.update(items: transactions2)
//                } catch {
//                    self.handleError(error: error)
//                }
//            case .failure(let error):
//                self.handleError(error: error)
//            }
//        }
    }

    @objc func fetchPending() {
       // fetchPendingTransactions()
    }

    @objc func fetchLatest() {
        fetchTransactions()
    }

    func handleError(error: Error) {
        delegate?.didUpdate(result: .failure(TransactionError.failedToFetch))
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
    }
}
