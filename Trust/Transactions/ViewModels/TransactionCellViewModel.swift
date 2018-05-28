// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit

struct TransactionCellViewModel {

    let transaction: TransactionHalyk
    let chainState: ChainState
    let shortFormatter = HalykNumberFormatter.short
    let longFormatter = HalykNumberFormatter.full

    init(
        transaction: TransactionHalyk,
        chainState: ChainState
    ) {
        self.transaction = transaction
        self.chainState = chainState
    }

    var confirmations: Int {
        return 1
    }

    var state: TransactionState {
        if confirmations == 0 {
            return .pending
        }
        return .completed
    }

    private var operationTitle: String? {
        return transaction.txid
    }

    var title: String {
        switch state {
        case .completed:
            switch transaction.type {
            case .In: return "\(NSLocalizedString("transactions.status.received", value: "Received", comment: ""))"
            case .Out: return "\(NSLocalizedString("transactions.status.sent", value: "Sent", comment: ""))"
            case .Pending: return "\(NSLocalizedString("transactions.status.pending", value: "Pending", comment: ""))"
            }
        case .error: return "Error"
        case .pending:
            switch transaction.type {
            case .In: return "\(NSLocalizedString("transactions.status.received", value: "Received", comment: ""))"
            case .Out: return "\(NSLocalizedString("transactions.status.sent", value: "Sent", comment: ""))"
            case .Pending: return "\(NSLocalizedString("transactions.status.pending", value: "Pending", comment: ""))"
            }
        }
    }

    var subTitle: String {
        switch transaction.type {
        case .In, .Out, .Pending: return "\(operationTitle ?? "")"
        }
    }

    var subTitleTextColor: UIColor {
        return Colors.gray
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.thin)
    }

    var amount: String {
        let value: String = {
            return shortFormatter.string(from: transaction.amount)
        }()
        guard value != "0" else { return value }
        switch transaction.type {
        case .In: return "+\(value)"
        case .Out: return "-\(value)"
        case .Pending: return "-\(value)"
        }
    }

    var amountTextColor: UIColor {
        let value: String = {
            return shortFormatter.string(from: transaction.amount)
        }()
        guard value != "0" else { return Colors.black }
        switch transaction.type {
        case .In: return Colors.green
        case .Out, .Pending: return Colors.red
        }
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
    }

    var backgroundColor: UIColor {
        switch state {
        case .completed:
            return .white
        case .error:
            return Colors.veryLightRed
        case .pending:
            return Colors.veryLightOrange
        }
    }

    var statusImage: UIImage? {
        switch state {
        case .error: return R.image.transaction_error()
        case .completed:
            switch transaction.type {
            case .In: return R.image.transaction_received()
            case .Out: return R.image.transaction_sent()
            case .Pending: return R.image.transaction_pending()
            }
        case .pending:
            return R.image.transaction_pending()
        }
    }
}
