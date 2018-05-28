// Copyright HalykCoin. All rights reserved.

import Foundation
import APIKit

struct CreateWalletRequestHalyk: APIKit.Request {
    typealias Response = String

    var baseURL: URL {
        let config = Config()
        return config.halykURL
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/createWallet"
    }

    var parameters: Any? {
        return [
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let response = object as? [String: AnyObject],
            let dataResponse: HalykResponse = .from(json: response),
            let idString = dataResponse.data as? String {
            return idString
        } else {
            throw CastError(actualValue: object, expectedType: Response.self)
        }
    }
}
