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
                    
                    
                    let user = User(name: data["name"] as? String, email: data["email"] as? String, id: userId)
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
    func addProfilePicture(url: String? ) async {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            do {
                let document = try await docRef.getDocument()
                if let data = document.data(), document.exists {
                    try await docRef.updateData(
                        [   "name" : self.userData?.name,
                            "email" : self.userData?.email,
                            "profileImageUrl" : url,
                            "id": userId
                        ]
                    )
                    self.userData?.profileImageUrl = url
                }
            }
            catch {
                print("Error uploading profileURL \(error)")
            }
        }
    }
}
