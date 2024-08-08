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

@MainActor class UserViewModel: ObservableObject {
    @Published var userData: User? = nil
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
                            let accountID = accountDict["id"] as? String {
                                let account = Account(name: accountName, password: accountPassword, id: accountID)
                                accounts.append(account)
                            }
                        }
                    }
                    let user = User(name: data["name"] as? String, email: data["email"] as? String, id: userId, accounts: accounts)
                    self.userData = user
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
                "id": account.id
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
            let accountData: [String: Any] = [
                "name": account.name,
                "password": account.password,
                "id": account.id
            ]
            do {
                try await docRef.updateData([
                    "accounts": FieldValue.arrayRemove([accountData])
                ])
                
            } catch {
                print("Error deleting document: \(error)")
            }
        }
        
    }
    
    func editAccount(account: Account) async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            do {
                let document = try await docRef.getDocument()
                if document.exists, var data = document.data(), var accountsData = data["accounts"] as? [[String: Any]] {
                    if let index = accountsData.firstIndex(where: { $0["id"] as? String == account.id }) {
                        print("Found account at index: \(index)")
                        accountsData[index]["name"] = account.name
                        accountsData[index]["password"] = account.password
                        print("Updated account data: \(accountsData[index])")
                        print("Accounts data to be updated: \(accountsData)")
                        try await docRef.updateData([
                            "accounts": accountsData
                        ])
                        print("Firestore document updated successfully")

                        if var userAccounts = userData?.accounts, let userIndex = userAccounts.firstIndex(where: { $0.id == account.id }) {
                            userAccounts[userIndex] = account
                            self.userData?.accounts = userAccounts
                            print("Local userData updated")
                        }
                        
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
}
