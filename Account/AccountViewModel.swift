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
    @Published var isEmpty: Bool = true;
    
    let db = Firestore.firestore()
    
    func getAccountData(key: SymmetricKey) async {
            if let userId = Auth.auth().currentUser?.uid {
                do {
                    let docRef = db.collection("users").document(userId).collection("accounts")
                    let querySnapshot = try await docRef.getDocuments()
                    var accountsArray: [Account] = []
                    var friendsArray: [Friend] = []
                    for document in querySnapshot.documents {
                        let data = document.data()
                        
                        if let accountName = data["name"] as? String,
                           let accountPassword = data["password"] as? String,
                           let accountPrice = data["price"] as? Double,
                           let accountId = data["id"] as? String {
                            if let authorizedUsers = data["authorizedUsers"] as? [String] {
                                
                                for friendID in authorizedUsers {
                                    print("hello")
                                    let friendDocRef = db.collection("users").document(friendID)
                                    let friendQuerySnapshot = try await friendDocRef.getDocument()
                                    let friendData = friendQuerySnapshot.data()
                                    
                                    if let friendName = friendData?["name"] as? String,
                                       let friendEmail = friendData?["email"] as? String,
                                       let friendUrl = friendData?["profileImageUrl"] as? String {
                                        print("friend Name \(friendName)")
                                        let newFriend = Friend(email: friendEmail, name: friendName, profileImageUrl: friendUrl, id: friendID)
                                        print(newFriend.email)
                                        friendsArray.append(newFriend)
                                        
                                    }
                                    
                                    
                                    
                                }
                                let account = Account(name: accountName, password: accountPassword, id: accountId, price: accountPrice, authorizedUsers: friendsArray)
                                accountsArray.append(account)
                               
                            }
                            else {
                                let account = Account(name: accountName, password: accountPassword, id: accountId, price: accountPrice)
                                accountsArray.append(account)
                            }
                        }
                    }
                    self.accountData = accountsArray
                    isEmpty = self.accountData.isEmpty
                    self.decryptPasswords(key: key)
                    self.calculateTotalCost()
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
    
    func addAuthorizedUsers(authorizedUsers: Set<Friend>, account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let docRef = db.collection("users").document(userId).collection("accounts")
                let querySnapshot = try await docRef.getDocuments()
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    let accountID = data["id"] as? String
                    
                    if accountID == account.id {
                        if let index = self.accountData.firstIndex(where: { $0.id == account.id }) {
                           
                            let authorizedUserIds: [String] = authorizedUsers.map { $0.id }
                           
                            try await docRef.document(document.documentID).updateData([
                                "authorizedUsers": authorizedUserIds
                            ])
                            
                            self.accountData[index].authorizedUsers = Array(authorizedUsers)
                        }
                    }
                }
            } catch {
                print("Error updating document \(error)")
            }
        }
    }


}
