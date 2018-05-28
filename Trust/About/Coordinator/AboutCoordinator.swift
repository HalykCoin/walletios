// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class AboutCoordinator: Coordinator {
    let navigationController: UINavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []

    lazy var rootViewController: AboutViewController = {
        return self.makeAboutViewController()
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore
        ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
    }

    func start() {
        showAbout()
    }

    func showAbout() {
        navigationController.viewControllers = [rootViewController]
    }

    func makeAboutViewController() -> AboutViewController {
        let controller = AboutViewController(account: session.account)
        return controller
    }
}
