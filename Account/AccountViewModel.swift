//
//  AccountViewModel.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
class AccountViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    
//     func addAccount(account: Account) async  {
//        let account_data = [
//            "name": account.name,
//            "password": account.password
//        ]
//        if let userId = Auth.auth().currentUser?.uid {
//            let docRef = db.collection("users").document(userId)
//            do {
//                try await docRef.updateData([
//                    "accounts": FieldValue.arrayUnion([account_data])
//                ])
//
//            } catch {
//                print("Error Loading Document")
//            }
//        }
//    }
    
}
