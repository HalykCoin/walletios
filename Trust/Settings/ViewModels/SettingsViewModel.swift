// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SettingsViewModel {

    private let isDebug: Bool

    init(
        isDebug: Bool = false
    ) {
        self.isDebug = isDebug
    }

    var servers: [String] {
        let list: [RPCServer] = {
            if isDebug {
                return [
                    RPCServer.main,
                    RPCServer.kovan,
                    RPCServer.ropsten,
                    RPCServer.oraclesTest,
                ]
            }
            return [
                RPCServer.main,
                RPCServer.kovan,
                RPCServer.ropsten,
            ]
        }()
        return list.map { $0.name }
    }

    var passcodeTitle: String {
        switch BiometryAuthenticationType.current {
        case .faceID, .touchID:
            return String(
                format: NSLocalizedString("settings.biometricsEnabled", value: "Passcode / %@)", comment: ""),
                BiometryAuthenticationType.current.title
            )
        case .none:
            return NSLocalizedString("settings.biometricsDisabled", value: "Passcode", comment: "")
        }
    }
}
