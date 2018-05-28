// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import OnePasswordExtension
import BonMot
import QRCodeReaderViewController

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: FormViewController {

    let keystore: Keystore
    private let viewModel = ImportWalletViewModel()

    struct Values {
        static let segment = "segment"
        static let keystore = "keystore"
        static let privateKey = "privateKey"
        static let password = "password"
    }

    var segmentRow: SegmentedRow<String>? {
        return form.rowBy(tag: Values.segment)
    }

    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }

    var privateKeyRow: TextAreaRow? {
        return form.rowBy(tag: Values.privateKey)
    }

    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }

    lazy var onePasswordCoordinator: OnePasswordCoordinator = {
        return OnePasswordCoordinator(keystore: self.keystore)
    }()

    weak var delegate: ImportWalletViewControllerDelegate?

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.import_options(), style: .done, target: self, action: #selector(importOptions))

//        if OnePasswordExtension.shared().isAppExtensionAvailable() {
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//                image: R.image.onepasswordButton(),
//                style: .done,
//                target: self,
//                action: #selector(onePasswordImport)
//            )
//        }

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.demo()
            }
        }

        form =

            Section(
                header: NSLocalizedString("import.enterKey", value: "Insert key of wallet", comment: ""),
                footer: NSLocalizedString("import.enterKey.instruction", value: "You can restore access to your wallet by entering the key that you got after your wallet has been generated", comment: "")
            )

//            +++ Section {
//                var header = HeaderFooterView<InfoHeaderView>(.class)
//                header.height = { 90 }
//                header.onSetupView = { (view, section) -> Void in
//                                        view.label.attributedText = "Importing wallet as easy as creating".styled(
//                                            with:
//                                            .color(UIColor(hex: "6e6e72")),
//                                            .font(UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
//                                            .lineHeightMultiple(1.25)
//                                        )
//                                        view.logoImageView.image = R.image.create_wallet_import()
//                }
//                $0.header = header
//            }

//            <<< SegmentedRow<String>(Values.segment) {
//                $0.options = [
//                    ImportSelectionType.keystore.title,
//                    ImportSelectionType.privateKey.title,
//                ]
//                $0.value = ImportSelectionType.keystore.title
//            }

//            <<< AppFormAppearance.textArea(tag: Values.keystore) {
//                $0.placeholder = "Keystore JSON"
//                $0.textAreaHeight = .fixed(cellHeight: 140)
//                $0.add(rule: RuleRequired())
//
//                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
//                    return self.segmentRow?.value != ImportSelectionType.keystore.title
//                })
//            }

            <<< AppFormAppearance.textArea(tag: Values.privateKey) {
                $0.placeholder = NSLocalizedString("import.enterKey.placeholder", value: "You can type key here", comment: "")
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.add(rule: PrivateKeyRule())
            }

//            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
//                $0.validationOptions = .validatesOnDemand
//                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
//                    return self.segmentRow?.value != ImportSelectionType.keystore.title
//                })
//            }.cellUpdate { cell, _ in
//                cell.textField.isSecureTextEntry = true
//                cell.textField.textAlignment = .left
//                cell.textField.placeholder = "Password"
//            }

            +++ Section("")

            <<< AppFormAppearance.button(NSLocalizedString("import.choseFile", value: "Chose from file", comment: "")) {
                $0.title = $0.tag
                }.onCellSelection { [unowned self] (_, _) in
                    self.showDocumentPicker()
                }.cellSetup { cell, _ in
                    cell.imageView?.image = R.image.importFile()
            }

            +++ Section("")

            <<< AppFormAppearance.button(NSLocalizedString("Generic.ScanQR", value: "Scan QR-code", comment: "")) {
                $0.title = $0.tag
                }.onCellSelection { [unowned self] (_, _) in
                    self.openReader()
                }.cellSetup { cell, _ in
                    cell.imageView?.image = R.image.importQrCode()
            }

            +++ Section("")

            <<< ButtonRow(NSLocalizedString("importWallet.importButton", value: "Import", comment: "")) {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] _, _ in
                self.importWallet()
            }
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    func didImport(account: Account) {
        delegate?.didImportAccount(account: account, in: self)
    }

    func importWallet() {
        let validatedError = privateKeyRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let privateKeyInput = privateKeyRow?.value?.trimmed ?? ""

        displayLoading(text: NSLocalizedString("importWallet.importingIndicatorTitle", value: "Importing wallet...", comment: ""), animated: false)

        let importType = ImportType.privateKey(privateKey: privateKeyInput)

        keystore.importWallet(id: privateKeyInput) { result in
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                self.didImport(account: account)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    func onePasswordImport() {
        onePasswordCoordinator.importWallet(in: self) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let password, let keystore):
                self.keystoreRow?.value = keystore
                self.keystoreRow?.reload()
                self.passwordRow?.value = password
                self.passwordRow?.reload()
                self.importWallet()
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    @objc func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoAccount = Account(
            address: Address(address: "")
        )
        delegate?.didImportAccount(account: demoAccount, in: self)
    }

    @objc func importOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Import Wallet Options", message: .none, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.addAction(UIAlertAction(title: "iCloud/Dropbox/Google Drive", style: .default) { _ in
            self.showDocumentPicker()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        present(alertController, animated: true)
    }

    @objc func showDocumentPicker() {
        let types = ["public.text", "public.content", "public.item", "public.data"]
        let controller = UIDocumentPickerViewController(documentTypes: types, in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension ImportWalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let text = try? String(contentsOfFile: url.path)
            privateKeyRow?.value = text
            privateKeyRow?.reload()
        }
    }
}

extension ImportWalletViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        if let text = result,
            let json = convertToDictionary(text: text),
            let id = json["id"] as? String {
            privateKeyRow?.value = id
            privateKeyRow?.reload()
        }
    }
}
