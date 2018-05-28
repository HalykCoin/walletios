// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct HalykResponse {
    let method: String
    let success: Bool
    let data: AnyObject
    
    init(method: String, success: Bool, data: AnyObject) {
        self.method = method
        self.success = success
        self.data = data
    }
}

extension HalykResponse {
    static func from(json: [String: AnyObject]) -> HalykResponse? {

        let method = json["method"] as? String ?? ""
            let success = json["success"] as? Bool ?? false
            let data = json["data"] as AnyObject

            return HalykResponse(
                method: method,
                success: success,
                data: data
            )
    }
}
