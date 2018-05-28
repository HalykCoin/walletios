// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result

protocol Keystore {
    var hasAccounts: Bool { get }
    var hasId: Bool { get }
    var accounts: [Account] { get }
    var currentAddress: String { get }
    var currentId: String { get }
    var recentlyUsedAccount: Account { get set }
    static var current: String? { get }
    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)
    func importWallet(id: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)
    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void)
    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)
    func createAccout(password: String) -> Account
    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeystoreError>
    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError>
    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError>
    func exportAsQR(account: Account, password: String) -> Result<String, KeystoreError>
    func exportPlain(account: Account) -> Result<String, KeystoreError>
    func delete(account: Account) -> Result<Void, KeystoreError>
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError>
    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError>
    func getPassword(for account: Account) -> String?
    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError>
}
