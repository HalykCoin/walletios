// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import BigInt

struct TransferRequestHalyk: APIKit.Request {
    typealias Response = [String: AnyObject]

    let id: String
    let address: String
    let paymentId: String
    let amount: Int
    let mixIn: Int = 1

    var baseURL: URL {
        let config = Config()
        return config.halykURL
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/transfer"
    }

    var parameters: Any? {
        return [
            "id": id,
            "address": address,
            "amount": amount,
            "paymentId": paymentId,
            "mixIn": mixIn
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let response = object as? [String: AnyObject],
            let dataResponse: HalykResponse = .from(json: response),
            let transferData = dataResponse.data as? [String: AnyObject]
        {
            return transferData
        } else {
            throw CastError(actualValue: object, expectedType: Response.self)
        }
    }
}
