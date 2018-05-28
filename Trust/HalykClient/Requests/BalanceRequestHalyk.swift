import Foundation
import APIKit

struct BalanceRequestHalyk: APIKit.Request {
    typealias Response = Balance

    let id: String
    
    var baseURL: URL {
        let config = Config()
        return config.halykURL
    }
    
    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/getBalance"
    }
    
    var parameters: Any? {
        return [
            "id": id,
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if
            let response = object as? [String: AnyObject],
            let dataResponse: HalykResponse = .from(json: response),
            let data = dataResponse.data as? [String: AnyObject],
            let balance: Balance = .from(json: data) {
            return balance
        } else {
            throw CastError(actualValue: object, expectedType: Response.self)
        }
    }
}
