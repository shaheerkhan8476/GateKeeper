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
import PhotosUI
import FirebaseStorage
import SwiftUI

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
                do {
                    self.userData = try document.data(as: User.self)
                } catch {
                    print("failed to decode User: \(error)")
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
                if (document.data() != nil), document.exists {
                    try await docRef.updateData(
                        [   "name" : self.userData?.name as Any,
                            "email" : self.userData?.email as Any,
                            "profileImageUrl" : url as Any,
                            "id": userId
                        ]
                    )
                    self.userData?.profileImageUrl = url
                }
                await self.fetchUserData()
            }
            catch {
                print("Error uploading profileURL \(error)")
            }
        }
  
    }
    
    func uploadProfilePicture(imageData: Data) async {
        let storageReference = Storage.storage().reference().child("profile_images/\(userData?.id).jpg")
        if ((userData?.profileImageUrl) != nil) {
            do {
              try await storageReference.delete()
            } catch {
              print("Error deleting profile picture \(error)")
            }
            
            storageReference.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Picture upload failed: \(error.localizedDescription)")
                    return
                }
                storageReference.downloadURL { url, error in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                        return
                    }
                    if let url = url {
                        print("Success with URL: \(url.absoluteString)")
                        Task {
                            await self.addProfilePicture(url: url.absoluteString)
                        }
                    }
                }
            }
        } else {
            storageReference.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Picture upload failed: \(error.localizedDescription)")
                    return
                }
                storageReference.downloadURL { url, error in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                        return
                    }
                    if let url = url {
                        print("Success with URL: \(url.absoluteString)")
                        Task {
                            await self.addProfilePicture(url: url.absoluteString)
                        }
                    }
                }
            }
        }
        
    }
    
}
