// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BackupCoordinatorDelegate: class {
    func didCancel(coordinator: BackupCoordinator)
    func didFinish(account: Account, in coordinator: BackupCoordinator)
}

class BackupCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: BackupCoordinatorDelegate?
    let keystore: Keystore
    let account: Account
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        keystore: Keystore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.account = account
    }

    func start() {
        export(for: account)
    }

    func finish(completed: Bool) {
        if completed {
            delegate?.didFinish(account: account, in: self)
        } else {
            delegate?.didCancel(coordinator: self)
        }
    }

    func presentActivityViewController(for account: Account, password: String, completion: @escaping (Bool) -> Void) {
        let result = keystore.exportPlain(account: account)

        navigationController.displayLoading(
            text: NSLocalizedString("export.presentBackupOptions", value: "Preparing backup options...", comment: "")
        )

        switch result {
        case .success(let value):
            if let file = createDatFile(dataString: value) {
                let activityViewController = UIActivityViewController(
                    activityItems: [file],
                    applicationActivities: nil
                )
                activityViewController.completionWithItemsHandler = { _, result, _, _ in
                    completion(result)

                }
                activityViewController.popoverPresentationController?.sourceView = navigationController.view
                navigationController.present(activityViewController, animated: true) { [unowned self] in
                    self.navigationController.hideLoading()
                }
            }
        case .failure(let error):
            navigationController.hideLoading()
            navigationController.displayError(error: error)
        }
    }

    func createDatFile(dataString: String) -> URL? {

        let fileName = "walletaccesskey.dat"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        do {
            try dataString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)

        } catch {
            print("Failed to create file")
            print("\(error)")
        }

        return path
    }

    func presentShareActivity(for account: Account, password: String) {
        self.presentActivityViewController(for: account, password: "") { completed in
            self.finish(completed: completed)
        }
    }

    func export(for account: Account) {
//            let verifyController = UIAlertController.askPassword(
//                title: NSLocalizedString("export.enterPasswordWallet", value: "Enter password to export your wallet", comment: "")
//            ) { result in
//                switch result {
//                case .success(let newPassword):
//                    self.presentShareActivity(
//                        for: account,
//                        password: newPassword
//                    )
//                case .failure: break
//                }
//            }
//            navigationController.present(verifyController, animated: true, completion: nil)

        self.presentShareActivity(
            for: account,
            password: ""
        )
    }
}
