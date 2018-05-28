// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka

public struct PrivateKeyRule<T: Equatable>: RuleType {

    public init(msg: String = NSLocalizedString("import.key.invalid", value: "Key must be 255 characters long", comment: "")) {
        self.validationError = ValidationError(msg: msg)
    }

    public var id: String?
    public var validationError: ValidationError

    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            return (str.count != 255) ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
