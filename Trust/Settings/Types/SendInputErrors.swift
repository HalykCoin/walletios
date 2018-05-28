// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SendInputErrors: LocalizedError {
    case emptyClipBoard
    case invalidAddress
    case invalidPurchaseId
    case wrongInput

    var errorDescription: String? {
        switch self {
        case .emptyClipBoard:
            return NSLocalizedString("send.emptyClipBoard", value: "Empty ClipBoard", comment: "")
        case .invalidAddress:
            return NSLocalizedString("send.address.invalid", value: "Invalid Halykcoin Address", comment: "")
        case .invalidPurchaseId:
            return NSLocalizedString("send.paymentId.invalid", value: "Invalid Halykcoin Purchase ID", comment: "")
        case .wrongInput:
            return NSLocalizedString("send.wrongInput", value: "Wrong Input", comment: "")
        }
    }
}
