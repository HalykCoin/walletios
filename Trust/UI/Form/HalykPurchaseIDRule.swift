// Copyright Halykcoin. All rights reserved.

import Foundation
import Eureka

public struct HalykPurchaseIDRule<T: Equatable>: RuleType {

    public init(msg: String = NSLocalizedString("send.paymentId.invalid", value: "Invalid Halykcoin Purchase ID", comment: "")) {
        self.validationError = ValidationError(msg: msg)
    }

    public var id: String?
    public var validationError: ValidationError

    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            if str.isEmpty { return nil }
            return str.count != 64  ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
