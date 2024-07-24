//
//  AddAccountView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/15/24.
//

import SwiftUI

struct AddAccountView: View {
    @Binding var showAddAccountSheet: Bool
    @State private var accountName: String = ""
    @State private var accountPassword: String = ""
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        VStack {
            TextField("Enter Account Name", text: $accountName)
            Divider()
            SecureField("Enter Account Password", text: $accountPassword)
        }
        .padding()
        VStack {
            Button(action: {
                if accountName != "" && accountPassword != "" {
                    let new_account = Account(name: accountName, password: accountPassword)
                    Task {
                        await userViewModel.addAccount(account: new_account)
                    }
                }
                showAddAccountSheet = false
            }, label: {
                Text("Add Account")
            }).buttonStyle(.borderedProminent)
                .padding()
        }
        .padding()
    }
}

//#Preview {
//    AccountView()
//}
