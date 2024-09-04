//
//  User.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/8/24.
//

import Foundation
import CryptoKit

class User: Identifiable, Codable{
    var name: String?
    var email: String?
    var id: String?
    var profileImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case email = "email"
        case id = "id"
        case profileImageUrl = "profileImageUrl"
    }
    
    init( name: String? = nil, email: String? = nil, id: String? = nil, profileImageUrl: String? = nil) {
        self.name = name
        self.email = email
        self.id = id
        self.profileImageUrl = profileImageUrl
    }
    
    func retrieveSymmetricKey() -> SymmetricKey {
        if let keyData = KeychainHelper.retrieveData(forService: "symkey", account: self.id ?? "GateKeeper") {
            let key: SymmetricKey = SymmetricKey(data: keyData)
            return key
        } else {
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data(Array($0)) }
            let _ = KeychainHelper.storeData(data: keyData, forService: "symkey", account: self.id ?? "GateKeeper")
            print("Generated and stored new key")
            return key
        }
    }
}
