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

class UserViewModel: ObservableObject {
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
                            let accountPassword = accountDict["password"] as? String {
                             let account = Account(name: accountName, password: accountPassword)
                             accounts.append(account)
                         }
                     }
                 }
                    let user = User(name: data["name"] as? String, id: userId, accounts: accounts)
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
                    "password": account.password
                ]
                let docRef = db.collection("users").document(userId)
                do {
                    try await docRef.updateData([
                        "accounts": FieldValue.arrayUnion([accountData])
                    ])
                    self.userData?.accounts?.append(account)
                    await fetchUserData()
                } catch {
                    print("Error updating document: \(error)")
                }
            }
        }
    func resetUserData() {
            self.userData = nil
        }
}
