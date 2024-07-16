//
//  AccountView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/15/24.
//

import SwiftUI

struct AccountView: View {
    @State private var accountName: String = ""
    @State private var accountPassword: String = ""
    var body: some View {
        VStack {
            TextField("Enter Account Name", text: $accountName)
            Divider()
            TextField("Enter Account Password", text: $accountPassword)
        }
        .padding()
    }
}

#Preview {
    AccountView()
}
