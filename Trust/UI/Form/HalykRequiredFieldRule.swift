// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka

public struct HalykRequiredFieldRule<T: Equatable>: RuleType {

    public init(msg: String = NSLocalizedString("send.amount.invalid", value: "Field required!", comment: "")) {
        self.validationError = ValidationError(msg: msg)
    }

    public var id: String?
    public var validationError: ValidationError

    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String{
            return str.isEmpty ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
