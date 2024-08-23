//
//  KeychainHelper.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/13/24.
//

import Foundation
import Security

class KeychainHelper {
    static func storeData(data: Data, forService service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    static func retrieveData(forService service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
           
        ]
        var item: CFTypeRef?
        let _ = SecItemCopyMatching(query as CFDictionary, &item)
        let data = item as? Data
        return data
        
    }
}

