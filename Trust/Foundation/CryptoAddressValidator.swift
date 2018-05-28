// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AddressValidatorType {
    case halyk

    var addressLength: Int {
        switch self {
        case .halyk: return 95
        }
    }
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .halyk) -> Bool {
        guard value?.count == 95 else {
            return false
        }
        return true
    }
}
