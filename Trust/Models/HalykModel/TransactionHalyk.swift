// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

enum TransactionSign {
    case In
    case Out
    case Pending
}

struct TransactionHalyk {

    let amount: BigInt
    let fee: BigInt
    let height: Int32
    let note: String
    let payment_id: String
    let subaddr_index: [String: Any]
    let date: Date
    let txid: String
    let type: TransactionSign
    let unlock_time: Int32
    
    init(amount: BigInt,
         fee: BigInt,
         height: Int32,
         note: String,
         payment_id: String,
         subaddr_index: [String: Any],
         date: Date,
         txid: String,
         type: TransactionSign,
         unlock_time: Int32) {
        self.amount = amount
        self.fee = fee
        self.height = height
        self.note = note
        self.payment_id = payment_id
        self.subaddr_index = subaddr_index
        self.date = date
        self.txid = txid
        self.type = type
        self.unlock_time = unlock_time
    }

    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncatedTxid(limit: Int, position: TruncationPosition = .middle, leader: String = "…") -> String {
        guard self.txid.count > limit else { return self.txid }

        switch position {
        case .head:
            return leader + self.txid.suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))

            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))

            return "\(self.txid.prefix(headCharactersCount))\(leader)\(self.txid.suffix(tailCharactersCount))"
        case .tail:
            return self.txid.prefix(limit) + leader
        }
    }

}

extension TransactionHalyk {
    static func from(json: [String: AnyObject]) -> TransactionHalyk? {

        let amount = json["amount"] as? Int ?? 0
        let fee = json["fee"] as? Int ?? 0
        let height = json["height"] as? Int32 ?? 0
        let note = json["note"] as? String ?? ""
        let payment_id = json["payment_id"] as? String ?? ""
        let subaddr_index = json["subaddr_index"] as? [String: Any] ?? [:]
        var date = Date()
        if let timestampInt = json["timestamp"] as? Double {
            date = Date(timeIntervalSince1970: timestampInt)
        }
        let txid = json["txid"] as? String ?? ""
        var inOut = TransactionSign.In
        if let typeStr = json["type"] as? String {
            switch typeStr {
            case "in": inOut = TransactionSign.In
            case "out": inOut = TransactionSign.Out
            case "pending": inOut = TransactionSign.Pending
            default:
                break
            }
        }
        let unlock_time = json["unlock_time"] as? Int32 ?? 0

        return TransactionHalyk(
            amount: BigInt(amount),
            fee: BigInt(fee),
            height: height,
            note: note,
            payment_id: payment_id,
            subaddr_index: subaddr_index,
            date: date,
            txid: txid,
            type: inOut,
            unlock_time: unlock_time
        )
    }
}
