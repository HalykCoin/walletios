// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .halyk: return false
        case .kovan, .ropsten, .oraclesTest: return false
        }
    }

    var exchangeAvailable: Bool {
        switch config.server {
        case .main, .ropsten, .oraclesTest, .halyk: return false
        case .kovan: return config.isDebugEnabled
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }
}
