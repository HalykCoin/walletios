// Copyright Halyk. All rights reserved.

import Foundation
import APIKit

struct TransactionsRequestHalyk: APIKit.Request {
    typealias Response = [TransactionHalyk]

    let id: String

    var baseURL: URL {
        let config = Config()
        return config.halykURL
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/getTransfers"
    }

    var parameters: Any? {
        return [
            "id": id
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let response = object as? [String: AnyObject],
            let dataResponse: HalykResponse = .from(json: response),
            let transactionsInOut = dataResponse.data as? [String: AnyObject]
        {
            var transactions = [TransactionHalyk]()
            if let transactionsInJSON = transactionsInOut["in"] as? [[String: AnyObject]] {
                for transaction in transactionsInJSON {
                    if let details: TransactionHalyk = .from(json: transaction) {
                        transactions.append(details)
                    }
                }
            }
            if let transactionsOutJSON = transactionsInOut["out"] as? [[String: AnyObject]] {
                for transaction in transactionsOutJSON {
                    if let details: TransactionHalyk = .from(json: transaction) {
                        transactions.append(details)
                    }
                }
            }
            if let transactionsPendingJSON = transactionsInOut["pending"] as? [[String: AnyObject]] {
                for transaction in transactionsPendingJSON {
                    if let details: TransactionHalyk = .from(json: transaction) {
                        transactions.append(details)
                    }
                }
            }
            return transactions
        } else {
            throw CastError(actualValue: object, expectedType: Response.self)
        }
    }
}
