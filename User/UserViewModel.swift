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
                    let user = User(name: data["name"] as? String, id: userId, accounts: [])
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
}
