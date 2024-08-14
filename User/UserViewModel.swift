//
//  UserViewModel.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CryptoKit

@MainActor class UserViewModel: ObservableObject {
    @Published var userData: User? = nil
    @Published var totalPrice: Double = 0.0
    let db = Firestore.firestore()
    func fetchUserData() async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            do {
                let document = try await docRef.getDocument()
                if let data = document.data(), document.exists {
                    var accounts: [Account] = []
                    if let accountsData = data["accounts"] as? [[String: Any]] {
                        for accountDict in accountsData {
                            if let accountName = accountDict["name"] as? String,
                               let accountPassword = accountDict["password"] as? String,
                               let accountID = accountDict["id"] as? String,
                               let accountPrice = accountDict["price"] as? Double{
                                let account = Account(name: accountName, password: accountPassword, id: accountID, price: accountPrice)
                                accounts.append(account)
                            }
                        }
                    }
                    let user = User(name: data["name"] as? String, email: data["email"] as? String, id: userId, accounts: accounts)
                    self.userData = user
                    self.decryptPasswords()
                    self.calculateTotalCost()
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting document: \(error)")
            }
        } else {
            print("No authenticated user found")
            return
        }
    }
    
    func addAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            let accountData: [String: Any] = [
                "name": account.name,
                "password": account.password,
                "id": account.id,
                "price": account.price > 0 ? account.price : 0
            ]
            let docRef = db.collection("users").document(userId)
            do {
                try await docRef.updateData([
                    "accounts": FieldValue.arrayUnion([accountData])
                ])
                self.userData?.accounts?.append(account)
                
            } catch {
                print("Error updating document: \(error)")
            }
        }
        await fetchUserData()
    }
    
    func deleteAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            do {
                let document = try await docRef.getDocument()
                if let data = document.data(), var accountsData = data["accounts"] as? [[String: Any]] {
                    if let index = accountsData.firstIndex(where: { $0["id"] as? String == account.id }) {
                        accountsData.remove(at: index)
                        try await docRef.updateData([
                            "accounts": accountsData
                        ])
                        userData?.accounts?.removeAll(where: { $0.id == account.id })
                        print("Account deleted successfully")
                        self.calculateTotalCost()
                    } else {
                        print("Account not found")
                    }
                }
            } catch {
                print("Error deleting document: \(error)")
            }
        } else {
            print("No authenticated user found")
        }
    }
    
    func editAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            do {
                let document = try await docRef.getDocument()
                if document.exists, let data = document.data(), var accountsData = data["accounts"] as? [[String: Any]] {
                    if let index = accountsData.firstIndex(where: { $0["id"] as? String == account.id }) {
                        accountsData[index]["name"] = account.name
                        accountsData[index]["password"] = account.password
                        accountsData[index]["price"] = account.price > 0 ? account.price : 0
                        try await docRef.updateData([
                            "accounts": accountsData
                        ])
                        print("Firestore document updated successfully")
                        if var userAccounts = userData?.accounts, let userIndex = userAccounts.firstIndex(where: { $0.id == account.id }) {
                            userAccounts[userIndex] = account
                            self.userData?.accounts = userAccounts
                            print("Local userData updated")
                        }
                        self.calculateTotalCost()
                    } else {
                        print("Account with ID \(account.id) not found in Firestore data")
                    }
                }
            } catch {
                print("Error updating document: \(error)")
            }
            print("Done")
        }
    }
    
    func resetUserData() {
        self.userData = nil
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
    
    func decryptData(encryptedData: Data, key: SymmetricKey) -> String? {
        do {
            
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    func retrieveSymmetricKey() -> SymmetricKey? {
        if let user = userData {
            if let key = user.retrieveSymmetricKey() {
                return key
            } else {
                print("Failed to retrieve the symmetric key.")
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func decryptPasswords() {
        if let accounts = userData?.accounts {
            for index in accounts.indices {
                if let key = retrieveSymmetricKey(),
                   let encryptedData = Data(base64Encoded: accounts[index].password),
                   let decryptedPassword = decryptData(encryptedData: encryptedData, key: key) {
                    userData?.accounts?[index].password = decryptedPassword
                } else {
                    print("Failed to decrypt password for account \(accounts[index].name)")
                }
            }
        }
    }
    
    func calculateTotalCost() {
            var total: Double = 0.0
            if let accounts = userData?.accounts {
                for account in accounts {
                    if account.price > 0 {
                        total += account.price
                    }
                }
            }
            totalPrice = total
        }
}
