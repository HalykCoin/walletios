// Copyright Halyk. All rights reserved.

import Foundation
import APIKit

struct AddressRequestHalyk: APIKit.Request {
    typealias Response = String

    let id: String

    var baseURL: URL {
        let config = Config()
        return config.halykURL
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/getAddress"
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
            let idString = dataResponse.data as? String {
            return idString
        } else {
            throw CastError(actualValue: object, expectedType: Response.self)
        }
    }
}
