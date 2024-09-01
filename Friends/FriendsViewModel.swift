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

class FriendsViewModel: ObservableObject {
    @Published var friendData: User? = nil
    let db = Firestore.firestore()
    func addFriend() async {
        let collectionRef = db.collection("users")
        
    }
}
