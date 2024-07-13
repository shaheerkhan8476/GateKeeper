//
//  User.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/8/24.
//

import Foundation

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
    }
}
