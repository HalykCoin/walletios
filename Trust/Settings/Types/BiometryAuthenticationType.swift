// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import LocalAuthentication

enum BiometryAuthenticationType {
    case touchID
    case faceID
    case none
}

extension BiometryAuthenticationType {
    var title: String {
        switch self {
        case .faceID: return NSLocalizedString("settings.biometrics.faceId", value: "FaceID", comment: "")
        case .touchID: return NSLocalizedString("settings.biometrics.touchId", value: "Touch ID", comment: "")
        case .none: return ""
        }
    }

    static var current: BiometryAuthenticationType {
        if #available(iOS 11.0, *) {
            switch LAContext().biometryType {
            case .touchID: return .touchID
            case .faceID: return .faceID
            case .none: return .none
            }
        }
        return .touchID
    }
}
