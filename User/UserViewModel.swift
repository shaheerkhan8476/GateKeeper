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
    enum UserViewModelError: Error {
        case notLoggedIn
    }
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
    func resetUserData() throws {
        try Auth.auth().signOut()
        self.userData = nil
    }
    func retrieveSymmetricKey() -> Result<SymmetricKey, UserViewModelError> {
        guard let user = userData else {
            return .failure(UserViewModelError.notLoggedIn)
        }
        
        return .success(user.retrieveSymmetricKey())
    }
}
