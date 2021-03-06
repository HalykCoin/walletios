// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SettingsAction {
    case exportPrivateKey
    case RPCServer
    case donate(address: Address)
    case pushNotifications(enabled: Bool)
    case switchWallet
    case switchWalletButtonClicked
}
