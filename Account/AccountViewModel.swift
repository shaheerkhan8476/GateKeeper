//
//  AccountViewModel.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/19/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CryptoKit
@MainActor class AccountViewModel: ObservableObject {
    @Published var accountData : [Account] = []
    @Published var totalPrice: Double = 0
    
    
    let db = Firestore.firestore()
    func getAccountData(key: SymmetricKey) async {
            if let userId = Auth.auth().currentUser?.uid {
                do {
                    let docRef = db.collection("users").document(userId).collection("accounts")
                    let querySnapshot = try await docRef.getDocuments()
                    var accountsArray: [Account] = []
                    for document in querySnapshot.documents {
                        let data = document.data()
                        if let accountName = data["name"] as? String,
                           let accountPassword = data["password"] as? String,
                           let accountPrice = data["price"] as? Double,
                           let accountId = data["id"] as? String {
                            let account = Account(name: accountName, password: accountPassword, id: accountId, price: accountPrice)
                            accountsArray.append(account)
                        }
                    }
                    self.accountData = accountsArray
                    self.decryptPasswords(key: key)
                } catch {
                    print("Error retrieving accounts: \(error)")
                }
            }
        }
    
    func addAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId).collection("accounts")
            let accountData: [String: Any] = [
                "name": account.name,
                "password": account.password,
                "id": account.id,
                "price": account.price > 0 ? account.price : 0
            ]
            do {
                try await docRef.addDocument(data: accountData)
                self.accountData.append(account)
            } catch {
                print("Error Adding account: \(error)")
            }
        }
       
    }
    
    func deleteAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let docRef = db.collection("users").document(userId).collection("accounts")
                let querySnapshot = try await docRef.getDocuments()
                for document in querySnapshot.documents {
                    let data = document.data()
                    let accountID = data["id"] as? String
                    if accountID == account.id {
                        try await docRef.document(document.documentID).delete()
                        if let index = self.accountData.firstIndex(where: { $0.id == account.id }) {
                        self.accountData.remove(at: index)
                        }
                        break
                    }
                }
            } catch {
                print("Error deleting document \(error)")
            }
        }
    }
    
    func editAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let docRef = db.collection("users").document(userId).collection("accounts")
                let querySnapshot = try await docRef.getDocuments()
                for document in querySnapshot.documents {
                    let data = document.data()
                    let accountID = data["id"] as? String
                    if accountID == account.id {
                        if let index = self.accountData.firstIndex(where: { $0.id == account.id }) {
                            self.accountData[index] = account
                            try await docRef.document(document.documentID).updateData([
                                "name": account.name,
                                "password": account.password,
                                "price": account.price > 0 ? account.price : 0,
                                "id": account.id
                            ])
                        }
                    }
                }
            } catch {
                print("Error editing document \(error)")
            }
        }
    }
    
    func calculateTotalCost() {
            var total: Double = 0.0
                for account in accountData {
                    if account.price > 0 {
                        total += account.price
                    }
                }
            totalPrice = total
        }
    
    func decryptData(encryptedData: Data, key: SymmetricKey) -> String? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                print("Failed to convert decrypted data to string.")
                return nil
            }
            print("Decrypted password: \(decryptedString)")
            return decryptedString
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    func decryptPasswords(key: SymmetricKey) {
            var updatedAccounts: [Account] = []
            for account in accountData {
                if let encryptedData = Data(base64Encoded: account.password),
                   let decryptedPassword = decryptData(encryptedData: encryptedData, key: key) {
                    account.password = decryptedPassword
                } else {
                    print("Failed to decrypt password for account \(account.name)")
                }
                updatedAccounts.append(account)
            }
            self.accountData = updatedAccounts
        }
    
    func encryptData(sensitive: String, key: SymmetricKey) -> Data? {
        do {
            let data: Data = sensitive.data(using: .utf8)!
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption failed: \(error)")
            return nil
        }
        
    }
    
}
