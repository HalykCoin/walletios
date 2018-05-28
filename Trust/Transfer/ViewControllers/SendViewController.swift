// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Geth
import Eureka
import JSONRPCKit
import APIKit
import QRCodeReaderViewController
import BigInt

protocol SendViewControllerDelegate: class {
    func didPressConfirm(
        transaction: UnconfirmedTransaction,
        transferType: TransferType,
        gasPrice: BigInt?,
        in viewController: SendViewController
    )
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController)
}

class SendViewController: FormViewController {

    private lazy var viewModel: SendViewModel = {
        return .init(transferType: self.transferType, config: Config())
    }()
    weak var delegate: SendViewControllerDelegate?

    struct Values {
        static let address = "address"
        static let amount = "amount"
        static let purchaseId = "purchaseId"
    }

    let session: WalletSession
    let transferType: TransferType

    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.address) as? TextFloatLabelRow
    }
    var purchaseIdRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.purchaseId) as? TextFloatLabelRow
    }
    var amountRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.amount) as? TextFloatLabelRow
    }
    private var gasPrice: BigInt?

    init(
        session: WalletSession,
        transferType: TransferType = .ether(destination: .none)
    ) {
        self.session = session
        self.transferType = transferType

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let pasteButton = Button(size: .normal, style: .borderlessBlue)
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setTitle(NSLocalizedString("Generic.Paste", value: "Paste", comment: ""), for: .normal)
        pasteButton.addTarget(self, action: #selector(pasteAction), for: .touchUpInside)

        let pastePurchaseIdButton = Button(size: .normal, style: .borderlessBlue)
        pastePurchaseIdButton.translatesAutoresizingMaskIntoConstraints = false
        pastePurchaseIdButton.setTitle(NSLocalizedString("Generic.Paste", value: "Paste", comment: ""), for: .normal)
        pastePurchaseIdButton.addTarget(self, action: #selector(pastePurchaseIdAction), for: .touchUpInside)

        let qrButton = UIButton(type: .custom)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)
        qrButton.addTarget(self, action: #selector(openReader), for: .touchUpInside)

        let recipientRightView = UIStackView(arrangedSubviews: [
            pasteButton,
            //qrButton,
            //.spacerWidth(1),
        ])
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.distribution = .equalSpacing
        recipientRightView.spacing = 10
        recipientRightView.axis = .horizontal

        let purchaseIdRightView = UIStackView(arrangedSubviews: [
            pastePurchaseIdButton,
            ])
        purchaseIdRightView.translatesAutoresizingMaskIntoConstraints = false
        purchaseIdRightView.distribution = .equalSpacing
        purchaseIdRightView.spacing = 10
        purchaseIdRightView.axis = .horizontal

        let maxButton = Button(size: .normal, style: .borderless)
        maxButton.translatesAutoresizingMaskIntoConstraints = false
        maxButton.setTitle("Max", for: .normal)
        maxButton.addTarget(self, action: #selector(useMaxAmount), for: .touchUpInside)

        let amountRightView = UIStackView(arrangedSubviews: [
            maxButton,
        ])
        amountRightView.translatesAutoresizingMaskIntoConstraints = false
        amountRightView.distribution = .equalSpacing
        amountRightView.spacing = 10
        amountRightView.axis = .horizontal

        form = Section()
            +++ Section("")

            <<< AppFormAppearance.textFieldFloat(tag: Values.address) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.recipientAddress", value: "Recipient Address", comment: "")
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.purchaseId) {
                $0.add(rule: HalykPurchaseIDRule())
                $0.validationOptions = .validatesOnDemand
                }.cellUpdate { cell, _ in
                    cell.textField.textAlignment = .left
                    cell.textField.placeholder = NSLocalizedString("send.recipientPurchaseId", value: "Recipient Payment ID", comment: "")
                    cell.textField.rightView = purchaseIdRightView
                    cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: HalykRequiredFieldRule())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "\(self.viewModel.symbol) " + NSLocalizedString("Send.AmountPlaceholder", value: "Amount", comment: "")
                cell.textField.keyboardType = .decimalPad
                //cell.textField.rightView = maxButton // TODO Enable it's ready
                cell.textField.rightViewMode = .always
            }

            +++ Section {
                $0.hidden = Eureka.Condition.function([Values.amount], { _ in
                    return self.amountRow?.value?.isEmpty ?? true
                })
            }

            +++ Section("")

            <<< AppFormAppearance.button(NSLocalizedString("Generic.ScanQR", value: "Scan QR-code", comment: "")) {
                $0.title = $0.tag
                }.onCellSelection { [unowned self] (_, _) in
                    self.openReader()
                }.cellSetup { cell, _ in
                    cell.imageView?.image = R.image.importQrCode()
        }

        getGasPrice()
    }

    func getGasPrice() {
        let request = EtherServiceRequest(batch: BatchFactory().create(GasPriceRequest()))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.gasPrice = BigInt(balance.drop0x, radix: 16)
            case .failure: break
            }
        }
    }

    func clear() {
        let fields = [addressRow, amountRow]
        for field in fields {
            field?.value = ""
            field?.reload()
        }
    }

    @objc func send() {
        let errors = form.validate()
        guard errors.isEmpty else { return }

        let addressString = addressRow?.value?.trimmed ?? ""
        let purchaseIdString = purchaseIdRow?.value?.trimmed ?? ""
        let amountString = amountRow?.value?.trimmed ?? ""

        let address = Address(address: addressString)

        let parsedValue: BigInt? = {
            switch transferType {
            case .ether, .exchange, .halyk: // exchange dones't really matter here
                return HalykNumberFormatter.full.number(from: amountString, units: .halyk)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            }
        }()

        guard let value = parsedValue else {
            return displayError(error: SendInputErrors.wrongInput)
        }

        let transaction = UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            address: address,
            purchaseId: purchaseIdString
        )
        self.delegate?.didPressConfirm(transaction: transaction, transferType: transferType, gasPrice: gasPrice, in: self)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    @objc func pasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }

        guard CryptoAddressValidator.isValidAddress(value) else {
            return displayError(error: SendInputErrors.invalidAddress)
        }

        addressRow?.value = value
        addressRow?.reload()

        activateAmountView()
    }

    @objc func pastePurchaseIdAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }

        guard value.count == 64 else {
            return displayError(error: SendInputErrors.invalidPurchaseId)
        }

        purchaseIdRow?.value = value
        purchaseIdRow?.reload()

        activateAmountView()
    }

    @objc func useMaxAmount() {
        guard let value = session.balance?.amountFull else { return }

        amountRow?.value = value
        amountRow?.reload()
    }

    func activateAmountView() {
        amountRow?.cell.textField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func separateKeyAndIv(string: String) -> [String] {
        let keyAndIvArr = string.components(separatedBy: ":")
        return keyAndIvArr
    }

}

extension SendViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        //guard let result = QRURLParser.from(string: result) else { return }
        if let scannetText = result {
            let keyAndIvArr = separateKeyAndIv(string: scannetText)
            var address = ""
            var amount = ""
            var purchaseId = ""

            for field in keyAndIvArr {
                switch field.count {
                case 95:
                    address = field
                case 64:
                    purchaseId = field
                case 0...63:
                    amount = field
                    if let amountInt: BigInt = BigInt(amount) {
                        amount = HalykNumberFormatter.full.string(from: amountInt)
                    }
                default:
                    address = field
                }
            }

            addressRow?.value = address
            addressRow?.reload()
            amountRow?.value = amount
            amountRow?.reload()
            purchaseIdRow?.value = purchaseId
            purchaseIdRow?.reload()


        }
    }
}
