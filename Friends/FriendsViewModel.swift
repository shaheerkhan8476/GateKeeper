//
//  FriendsViewModel.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/1/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@MainActor class FriendsViewModel: ObservableObject {
    enum FriendsViewModelError: Error {
        case userNotFound
        case cannotAddSelf
        case friendAlreadyExists
    }
    
    @Published var friendData: [Any] = []
    let db = Firestore.firestore()
    
    func addFriend(friend: String) async throws {
        if let userId = Auth.auth().currentUser?.uid {
            
            if friend == Auth.auth().currentUser?.email {
                throw FriendsViewModelError.cannotAddSelf
            }
            
            let collectionRef = db.collection("users")
            let docRef = db.collection("users").document(userId)
            
            do {
                let querySnapshot = try await collectionRef.whereField("email", isEqualTo: friend).getDocuments()
                
                if querySnapshot.documents.isEmpty {
                    throw FriendsViewModelError.userNotFound
                }
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    
                    if let email = data["email"] as? String,
                       let name = data["name"] as? String {
                        
                        let friendData: [String: Any] = [
                            "email": email,
                            "name": name
                        ]
                        
                        if let currentUserSnapshot = try? await docRef.getDocument(),
                           let currentUserData = currentUserSnapshot.data(),
                           let currentFriends = currentUserData["friends"] as? [[String: Any]] {
                            
                            let friendAlreadyExists = currentFriends.contains { friend in
                                if let friendEmail = friend["email"] as? String {
                                    return friendEmail == email
                                }
                                return false
                            }
                            
                            if friendAlreadyExists {
                                throw FriendsViewModelError.friendAlreadyExists
                            }
                        }
                        
                        try await docRef.updateData([
                            "friends": FieldValue.arrayUnion([friendData])
                        ])
                        self.friendData.append(friendData)
                        
                    } else {
                        print("Error: Name or email is missing in the document")
                    }
                }
            } catch {
                print("An unexpected error occurred: \(error)")
            }
        } else {
            throw FriendsViewModelError.userNotFound
        }
    }
}
