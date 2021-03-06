// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol PaymentCoordinatorDelegate: class {
    func didCancel(in coordinator: PaymentCoordinator)
}

class PaymentCoordinator: Coordinator {

    let session: WalletSession
    weak var delegate: PaymentCoordinatorDelegate?

    let flow: PaymentFlow
    var coordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let keystore: Keystore

    lazy var transferType: TransferType = {
        switch self.flow {
        case .send(let type):
            return type
        case .request:
            return .ether(destination: .none)
        }
    }()

    init(
        navigationController: UINavigationController = UINavigationController(),
        flow: PaymentFlow,
        session: WalletSession,
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.flow = flow
        self.keystore = keystore
    }

    func start() {
        switch flow {
        case .send(let type):
            let coordinator = SendCoordinator(
                transferType: type,
                navigationController: navigationController,
                session: session,
                keystore: keystore
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        case .request:
            let coordinator = RequestCoordinator(
                navigationController: navigationController,
                session: session
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancel() {
        delegate?.didCancel(in: self)
    }
}

extension PaymentCoordinator: SendCoordinatorDelegate {
    func didCancel(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
        cancel()
    }
}

extension PaymentCoordinator: RequestCoordinatorDelegate {
    func didCancel(in coordinator: RequestCoordinator) {
        removeCoordinator(coordinator)
        cancel()
    }
}
