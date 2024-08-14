//
//  User.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/8/24.
//

import Foundation
import CryptoKit
class User: Identifiable {
    var name: String?
    var email: String?
    var id: String?
    var accounts: [Account]? = []
    
    init( name: String? = nil, email: String? = nil, id: String? = nil, accounts: [Account]? = []) {
        self.name = name
        self.email = email
        self.id = id
        self.accounts = accounts
        if let key = retrieveSymmetricKey() {
                    print("Retrieved existing key")
                    
                } else {
                    
                    let key = SymmetricKey(size: .bits256)
                    let keyData = key.withUnsafeBytes { Data(Array($0)) }
                    KeychainHelper.storeData(data: keyData, forService: "symkey", account: self.id ?? "GateKeeper")
                    print("Generated and stored new key")
                   
                }
        
    }
    func retrieveSymmetricKey() -> SymmetricKey? {
        
        if let keyData = KeychainHelper.retrieveData(forService: "symkey", account: self.id ?? "GateKeeper") {
            let key: SymmetricKey = SymmetricKey(data: keyData)
            let keyData = key.withUnsafeBytes { Data(Array($0)) }
            let hexString = keyData.map { String(format: "%02hhx", $0) }.joined()
            let base64String = keyData.base64EncodedString()

            return key
        } else {
            
            return nil
        }
    }
    

    
}
