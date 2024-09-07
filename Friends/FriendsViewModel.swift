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
    public enum FriendsViewModelError: Error {
        case userNotFound
        case cannotAddSelf
        case friendAlreadyExists
    }
    
    @Published var friendData: [Friend] = []
    let db = Firestore.firestore()
    
    func getFriends() async throws {
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            var friendArray: [Friend] = []
            
            let data = try await docRef.getDocument()
            if data.exists {
                if let friendsRead = data["friends"] as? [[String: Any]] {
                    for friend in friendsRead {
                        if let name = friend["name"] as? String,
                           let email = friend["email"] as? String {
                            let newFriend = Friend(email: email, name: name)
                            friendArray.append(newFriend)
                        }
                    }
                }
                self.friendData = friendArray
            }
        }
    }

    func addFriend(friend: String) async throws {
        if let userId = Auth.auth().currentUser?.uid {
            if friend.lowercased() == Auth.auth().currentUser?.email?.lowercased() {
                throw FriendsViewModelError.cannotAddSelf
            }
            let collectionRef = db.collection("users")
            let docRef = db.collection("users").document(userId)
            
            let document = try await docRef.getDocument()
            if document.exists {
                if let currentUserData = document.data() {
                    let querySnapshot = try await collectionRef.whereField("email", isEqualTo: friend).getDocuments()
                    
                    if querySnapshot.documents.isEmpty {
                        throw FriendsViewModelError.userNotFound
                    }
                    for document in querySnapshot.documents {
                        let data = document.data()
                        if let email = data["email"] as? String,
                           let name = data["name"] as? String,
                           let friendID = data["id"] as? String {
                            let newFriend: Friend = Friend(email: email, name: name)
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
                            let newFriendData: [String: Any] = [
                                "email" : email,
                                "name" : name
                            ]
                            try await docRef.updateData([
                                "friends": FieldValue.arrayUnion([newFriendData])
                            ])
                            
                            let friendDocRef = db.collection("users").document(friendID)
                            
                           let currentUserData: [String: Any] = [
                                "email" : currentUserData["email"] as Any,
                                "name" : currentUserData["name"] as Any
                            ]
                            
                            try await friendDocRef.updateData([
                                "friends": FieldValue.arrayUnion([currentUserData])
                            ])
                            
                            self.friendData.append(newFriend)
                        } else {
                            print("Error: Name or email is missing in the document")
                        }
                    }
                } else {
                    print("Unknown Error occured with adding Friend ")
                }
            }
        }
    }
    func deleteFriend(friend: Friend) async {
        let friendEmail: String = friend.email
        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users").document(userId)
            let collectionRef = db.collection("users")
            if let document = try? await docRef.getDocument() {
                if document.exists {
                    if let data = document.data(),
                       let friendsRead = data["friends"] as? [[String: Any]] {
                        for friendDoc in friendsRead {
                            if let email = friendDoc["email"] as? String, email == friendEmail {
                                let friendRemove = friendDoc
                                do {
                                    try await docRef.updateData([
                                        "friends": FieldValue.arrayRemove([friendRemove])
                                    ])
                                    let querySnapshot = try await collectionRef.whereField("email", isEqualTo: friendEmail).getDocuments()
                                    if let friendDocument = querySnapshot.documents.first {
                                        let friendData = friendDocument.data()
                                        if let friendID = friendData["id"] as? String {
                                            let friendDocRef = db.collection("users").document(friendID)
                                            let currentUserData: [String: Any] = [
                                                "email": data["email"] as Any,
                                                "name": data["name"] as Any
                                            ]
                                            try await friendDocRef.updateData([
                                                "friends": FieldValue.arrayRemove([currentUserData])
                                            ])
                                        }
                                    }
                                    friendData.removeAll { existingFriend in
                                        existingFriend.email == friendEmail
                                    }
                                } catch {
                                    print("Error removing friend: \(error)")
                                }
                            }
                        }
                    }
                }
            } else {
                print("Error getting document")
            }
        }
    }
}
