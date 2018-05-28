// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didCancel(in coordinator: SettingsCoordinator)
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator)
}

class SettingsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let keystore: Keystore
    weak var delegate: SettingsCoordinatorDelegate?

    let pushNotificationsRegistrar = PushNotificationsRegistrar()
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [makeSettingsController()]
    }

    private func makeSettingsController() -> SettingsViewController {
        let controller = SettingsViewController()
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    @objc func export(in viewController: UIViewController) {
        let account = keystore.recentlyUsedAccount
        let coordinator = BackupCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        //viewController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    @objc func switchWallet(in viewController: UIViewController) {
        navigationController.confirm(
            title: NSLocalizedString("export.watchout.title", value: "Watch out!", comment: ""),
            message: NSLocalizedString("Settings.switch.watchout.text", value: "This action will disconnect you from current wallet, you must backup your wallet before switching to another, otherwise you may lose it with all it's founds.", comment: ""),
            okTitle: NSLocalizedString("Settings.switch.watchout.iunderstand", value: "Continue", comment: ""),
            okStyle: .destructive
        ) { result in
            switch result {
            case .success:
                self.disconnectFromWallet(in: viewController)
            case .failure:
                break
            }
        }
    }

    func disconnectFromWallet(in viewController: UIViewController) {
        let coordinator = WalletCoordinator(keystore: keystore)
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(.welcome)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didAction(action: SettingsAction, in viewController: SettingsViewController) {
        switch action {
        case .exportPrivateKey:
            export(in: viewController)
        case .RPCServer: break
        case .donate: break
        case .pushNotifications(let enabled):
            switch enabled {
            case true:
                pushNotificationsRegistrar.register()
            case false:
                pushNotificationsRegistrar.unregister()
            }
        case .switchWallet:
            break
        case .switchWalletButtonClicked:
            switchWallet(in: viewController)
        }
        delegate?.didUpdate(action: action, in: self)
    }
}

extension SettingsCoordinator: ExportCoordinatorDelegate {
    func didFinish(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCancel(in coordinator: ExportCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        self.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(self)
        self.delegate?.didUpdate(action: .switchWallet, in: self)
        if let settingsVC = navigationController.viewControllers[0] as? SettingsViewController {
            settingsVC.popMessage(message:NSLocalizedString("Settings.wallet.changed", value: "Wallet is chenged", comment: ""))
        }

    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCancel(in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: BackupCoordinatorDelegate {
    func didFinish(account: Account, in coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }

    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }
}
