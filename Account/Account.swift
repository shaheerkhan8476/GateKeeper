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
    init(name: String, password: String, id: String = UUID().uuidString) {
        self.name = name
        self.password = password
        self.id = id
    }
}
