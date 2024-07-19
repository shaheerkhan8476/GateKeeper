//
//  Account.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/10/24.
//

import Foundation
class Account: Identifiable {
    var name: String = ""
    var password: String = ""
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
}
