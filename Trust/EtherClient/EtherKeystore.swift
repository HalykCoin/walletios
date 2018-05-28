// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import Result
import KeychainSwift
import CryptoSwift
import APIKit

enum EtherKeystoreError: LocalizedError {
    case protectionDisabled
}

open class EtherKeystore: Keystore {

    struct Keys {
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
        static let id: String = "id"
    }

    private let keychain: KeychainSwift
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let gethKeyStorage: GethKeyStore
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly

    public init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix),
        keyStoreSubfolder: String = "/keystore"
    ) throws {
        if !UIApplication.shared.isProtectedDataAvailable {
            throw EtherKeystoreError.protectionDisabled
        }

        let keydir = datadir + keyStoreSubfolder
        self.keychain = keychain
        self.keychain.synchronizable = false
        self.gethKeyStorage = GethNewKeyStore(keydir, GethLightScryptN, GethLightScryptP)
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var currentAddress: String {
        return address ?? ""
    }

    var currentId: String {
        return id ?? ""
    }

    var hasId: Bool {
        if let idString = id {
            return !idString.isEmpty
        } else {
            return false
        }
    }

    var recentlyUsedAccount: Account {
        set {
            keychain.set(newValue.address.address, forKey: Keys.recentlyUsedAddress, withAccess: defaultKeychainAccess)
        }
        get {
            let recentAddr = Address(address: self.currentAddress)
            let recentId = self.currentId
            return Account(address: recentAddr, id: recentId)
        }
    }

    var id: String? {
        set {
            keychain.set(newValue ?? "", forKey: Keys.id, withAccess: defaultKeychainAccess)
        }
        get {
            return keychain.get(Keys.id)
        }
    }

    var address: String? {
        set {
            keychain.set(newValue ?? "", forKey: Keys.recentlyUsedAddress, withAccess: defaultKeychainAccess)
        }
        get {
            return keychain.get(Keys.recentlyUsedAddress)
        }
    }

    static var current: String? {
        do {
            return try EtherKeystore().address
        } catch {
            return .none
        }
    }

    // Async
    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        createHalykWallet(completion: completion)
    }

    func createHalykWallet(completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        let request = CreateWalletRequestHalyk()
        Session.send(request) { result in
            switch result {
            case .success(let idString):
                self.id = idString
                self.getHalykAddress(idString: idString, completion: completion)
            case .failure:
                completion(.failure(KeystoreError.failedToCreateWallet))
            }
        }
    }

    func getHalykAddress(idString: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        let request = AddressRequestHalyk(id: idString)
        Session.send(request) { result in
            switch result {
            case .success(let addressString):
                self.address = addressString
                self.id = idString
                let address = Address(address: addressString)
                let account = Account(address: address, id: idString)
                self.recentlyUsedAccount = account
                completion(.success(account))
            case .failure:
                completion(.failure(KeystoreError.failedToCreateWallet))
            }
        }
    }

    func importWallet(id: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        self.getHalykAddress(idString: id, completion: completion)
    }

    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keystore = self.convertPrivateKeyToKeystoreFile(
                privateKey: privateKey,
                passphrase: password
            )
            DispatchQueue.main.async {
                switch keystore {
                case .success(let result):
                    completion(.success(result.jsonString ?? ""))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password, newPassword: newPassword)
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    completion(.success(account))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func createAccout(password: String) -> Account {
        let gethAccount = try! gethKeyStorage.newAccount(password)
        let account: Account = .from(account: gethAccount)
        let _ = setPassword(password, for: account)
        return account
    }

    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeystoreError> {
        let data = value.data(using: .utf8)
        do {
            let gethAccount = try gethKeyStorage.importKey(data, passphrase: password, newPassphrase: newPassword)

            //Hack to avoid duplicate accounts
            let accounts = gethAccounts.filter { $0.getAddress().getHex() == gethAccount.getAddress().getHex() }
            if accounts.count >= 2 {
                do {
                    try gethKeyStorage.delete(gethAccount, passphrase: password)
                } catch {
                    return (.failure(.failedToImport(error)))
                }
                return (.failure(.duplicateAccount))
            }

            let account: Account = .from(account: gethAccount)
            let _ = setPassword(newPassword, for: account)
            return .success(account)
        } catch {
            return .failure(.failedToImport(error))
        }
    }

    var accounts: [Account] {
        return self.gethAccounts.map { Account(address: Address(address: $0.getAddress().getHex())) }
    }

    var gethAccounts: [GethAccount] {
        var finalAccounts: [GethAccount] = []
        let allAccounts = gethKeyStorage.getAccounts()
        let size = allAccounts?.size() ?? 0

        for i in 0..<size {
            if let account = try! allAccounts?.get(i) {
                finalAccounts.append(account)
            }
        }

        return finalAccounts
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError> {
        let result = exportAsQR(account: account, password: password)
        switch result {
        case .success(let encryptedQrData):
            return .success(encryptedQrData)
        case .failure(let error):
            return .failure(error)
        }
    }

    func exportPlain(account: Account) -> Result<String, KeystoreError> {
        let result = exportAsPlainText(account: account)
        switch result {
        case .success(let plainId):
            return .success(plainId)
        case .failure(let error):
            return .failure(error)
        }
    }

    func exportAsQR(account: Account, password: String) -> Result<String, KeystoreError> {
        let result = convertPrivateKeyToEncryptedString(privateKey: account.id, passphrase: password)
        switch result {
        case .success(let encryptedId):
            return .success(encryptedId)
        case .failure(let error):
            return .failure(error)
        }
    }

    func exportAsPlainText(account: Account) -> Result<String, KeystoreError> {
        return .success(account.id)
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            let data = try gethKeyStorage.exportKey(gethAccount, passphrase: password, newPassphrase: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func delete(account: Account) -> Result<Void, KeystoreError> {
        let gethAccount = getGethAccount(for: account.address)
        let password = getPassword(for: account)
        do {
            try gethKeyStorage.delete(gethAccount, passphrase: password)
            return .success(())
        } catch {
            return .failure(.failedToDeleteAccount)
        }
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            try gethKeyStorage.update(gethAccount, passphrase: password, newPassphrase: newPassword)
            return .success(())
        } catch {
            return .failure(.failedToUpdatePassword)
        }
    }

    func signTransaction(
        _ signTransaction: SignTransaction
    ) -> Result<Data, KeystoreError> {
        let gethAddress = GethNewAddressFromHex(signTransaction.address.address, nil)
        let transaction = GethNewTransaction(
            numericCast(signTransaction.nonce),
            gethAddress,
            signTransaction.amount,
            signTransaction.speed.gasLimit.gethBigInt,
            signTransaction.speed.gasPrice.gethBigInt,
            signTransaction.data
        )
        let password = getPassword(for: signTransaction.account)

        let gethAccount = getGethAccount(for: signTransaction.account.address)

        do {
            try gethKeyStorage.unlock(gethAccount, passphrase: password)
            defer {
                do {
                    try gethKeyStorage.lock(gethAccount.getAddress())
                } catch {}
            }
            let signedTransaction = try gethKeyStorage.signTx(
                gethAccount,
                tx: transaction,
                chainID: signTransaction.chainID
            )
            let rlp = try signedTransaction.encodeRLP()
            return .success(rlp)
        } catch {
            return .failure(.failedToSignTransaction)
        }
    }

    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.address)
    }

    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: account.address.address, withAccess: defaultKeychainAccess)
    }

    func getGethAccount(for address: Address) -> GethAccount {
        return gethAccounts.filter { Address(address: $0.getAddress().getHex()) == address }.first!
    }

    func convertPrivateKeyToEncryptedString(privateKey: String, passphrase: String) -> Result<String, KeystoreError> {
        let privateKeyBytes: [UInt8] = Array(privateKey.utf8)
        do {
//            let passphraseBytes: [UInt8] = Array(passphrase.utf8)
//            // reduce this number for higher speed. This is the default value, though.
//            let numberOfIterations = 2214
//            // derive key
//            let salt: [UInt8] = AES.randomIV(32)
//            let derivedKey = try PKCS5.PBKDF2(password: passphraseBytes, salt: salt, iterations: numberOfIterations, variant: .sha256).calculate()
//            // encrypt
//            let iv: [UInt8] = AES.randomIV(AES.blockSize)
//            let aes = try AES(key: Array(derivedKey[..<16]), blockMode: .CTR(iv: iv), padding: .noPadding)
//            let ciphertext = try aes.encrypt(privateKeyBytes).toHexString()
//            let decrypted = convertEncryptedStringToPrivateKey(privateKey: ciphertext, passphrase: passphrase)
            let key = passphrase
            let iv = "gqLOHUioQ0QjhuvI" // length == 16
            let s = privateKey
            let enc = try! aesEncrypt(string: s, keyAndIv: "\(key):\(iv)")
            let dec = try! aesDecrypt(string: enc, keyAndIv: "\(key):\(iv)")
            print(s) // string to encrypt
            print("enc:\(enc)") // 2r0+KirTTegQfF4wI8rws0LuV8h82rHyyYz7xBpXIpM=
            print("dec:\(dec)") // string to encrypt
            print("\(s == dec)") // true
            return .success(enc)
        } catch {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
    }

    func separateKeyAndIv(string: String) -> [String] {
        let keyAndIvArr = string.components(separatedBy: ":")
        return keyAndIvArr
    }

    func aesEncrypt(string: String, keyAndIv: String) throws -> String {
        let keyAndIvArr = separateKeyAndIv(string: keyAndIv)
        let key = keyAndIvArr[0]
        let iv = keyAndIvArr[1]
        let data = string.data(using: .utf8)!
        let encrypted = try! AES(key: key.bytes, blockMode: .CBC(iv: iv.bytes), padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.base64EncodedString()
    }

    func aesDecrypt(string: String, keyAndIv: String) throws -> String {
        let keyAndIvArr = separateKeyAndIv(string: keyAndIv)
        let key = keyAndIvArr[0]
        let iv = keyAndIvArr[1]
        let data = Data(base64Encoded: string)!
        let decrypted = try! AES(key: key.bytes, blockMode: .CBC(iv: iv.bytes), padding: .pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? ""
    }

    func convertEncryptedStringToPrivateKey(privateKey: String, passphrase: String) -> Result<String, KeystoreError> {
        let privateKeyBytes: [UInt8] = Array(privateKey.utf8)
        do {
            let passphraseBytes: [UInt8] = Array(passphrase.utf8)
            // reduce this number for higher speed. This is the default value, though.
            let numberOfIterations = 2214

            // derive key
            let salt: [UInt8] = AES.randomIV(32)
            let derivedKey = try PKCS5.PBKDF2(password: passphraseBytes, salt: salt, iterations: numberOfIterations, variant: .sha256).calculate()

            // decrypt
            let iv: [UInt8] = AES.randomIV(AES.blockSize)
            let aes = try AES(key: Array(derivedKey[..<16]), blockMode: .CTR(iv: iv), padding: .noPadding)
            let ciphertext = try aes.decrypt(privateKeyBytes)

            let result = String(bytes: ciphertext, encoding: String.Encoding.utf8) ?? ""

            return .success(result)
        } catch {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError> {
        guard let privateKeyData = Data(fromHexEncodedString: privateKey) else {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
        let privateKeyBytes: [UInt8] = Array(privateKeyData)
        do {
            let passphraseBytes: [UInt8] = Array(passphrase.utf8)
            // reduce this number for higher speed. This is the default value, though.
            let numberOfIterations = 2214

            // derive key
            let salt: [UInt8] = AES.randomIV(32)
            let derivedKey = try PKCS5.PBKDF2(password: passphraseBytes, salt: salt, iterations: numberOfIterations, variant: .sha256).calculate()

            // encrypt
            let iv: [UInt8] = AES.randomIV(AES.blockSize)
            let aes = try AES(key: Array(derivedKey[..<16]), blockMode: .CTR(iv: iv), padding: .noPadding)
            let ciphertext = try aes.encrypt(privateKeyBytes)

            // calculate the mac
            let macData = Array(derivedKey[16...]) + ciphertext
            let mac = SHA3(variant: .keccak256).calculate(for: macData)

            /* convert to JSONv3 */

            // KDF params
            let kdfParams: [String: Any] = [
                "prf": "hmac-sha256",
                "c": numberOfIterations,
                "salt": salt.toHexString(),
                "dklen": 32,
            ]

            // cipher params
            let cipherParams: [String: String] = [
                "iv": iv.toHexString(),
            ]

            // crypto struct (combines KDF and cipher params
            var cryptoStruct = [String: Any]()
            cryptoStruct["cipher"] = "aes-128-ctr"
            cryptoStruct["ciphertext"] = ciphertext.toHexString()
            cryptoStruct["cipherparams"] = cipherParams
            cryptoStruct["kdf"] = "pbkdf2"
            cryptoStruct["kdfparams"] = kdfParams
            cryptoStruct["mac"] = mac.toHexString()

            // encrypted key json v3
            let encryptedKeyJSONV3: [String: Any] = [
                "crypto": cryptoStruct,
                "version": 3,
                "id": "",
            ]
            return .success(encryptedKeyJSONV3)
        } catch {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
    }
}

extension Account {
    static func from(account: GethAccount) -> Account {
        return Account(
            address: Address(address: account.getAddress().getHex())
        )
    }
}
