// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan
    case ropsten
    case oraclesTest
    case halyk

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .oraclesTest: return 12648430
        case .halyk: return 2030
        }
    }

    var name: String {
        switch self {
        case .main: return "Halykcoin"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .oraclesTest: return "Oracles"
        case .halyk: return "Halykcoin"
        }
    }

    var isTestNetwork: Bool {
        switch self {
        case .main, .halyk: return false
        case .kovan, .ropsten, .oraclesTest: return true
        }
    }

    var symbol: String {
        switch self {
        case .main: return "HLC"
        case .kovan, .ropsten: return "ETH"
        case .oraclesTest: return "POA"
        case .halyk: return "HLC"
        }
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
            case RPCServer.oraclesTest.name: return .oraclesTest
            case RPCServer.halyk.name: return .halyk
            default: return .main
            }
        }()
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.oraclesTest.chainID: return .oraclesTest
            case RPCServer.halyk.chainID: return .halyk
            default: return .main
            }
        }()
    }
}
