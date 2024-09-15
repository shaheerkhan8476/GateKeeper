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
    var id: String
    var price: Double = 0.0
    var authorizedUsers: Array<Friend> = []
    init(name: String, password: String, id: String = UUID().uuidString, price: Double = 0.0, authorizedUsers: Array<Friend> = []) {
        self.name = name
        self.password = password
        self.id = id
        self.price = price
        self.authorizedUsers = authorizedUsers
    }
}
