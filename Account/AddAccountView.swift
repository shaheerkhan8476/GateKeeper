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
    @State private var accountPrice: String = ""
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        VStack {
            TextField("Enter Account Name", text: $accountName)
            Divider()
            SecureField("Enter Account Password", text: $accountPassword)
            Divider()
            TextField("Enter Monthly Price", text: $accountPrice)
        }
        .padding()
        VStack {
            Button(action: {
                if accountName != "" && accountPassword != "" {
                    Task {
                        switch userViewModel.retrieveSymmetricKey() {
                        case .success(let key):
                            // do the shit
                            // Encrypt the account password
                            if let encryptedPasswordData = accountViewModel.encryptData(sensitive: accountPassword, key: key) {
                                // Create a new account with the encrypted password
                                let encryptedPasswordString = encryptedPasswordData.base64EncodedString()
                                let newAccount = Account(name: accountName, password: encryptedPasswordString, price: Double(accountPrice) ?? 0.0)
                                // Add the account
                                await accountViewModel.addAccount(account: newAccount)
                                await accountViewModel.getAccountData(key: key)
                            } else {
                                print("Failed to encrypt password")
                            }
                        case .failure(let error):
                            // check what type of error this is and handle it accordingly
                            switch error {
                            case .notLoggedIn:
                                // user is not logged in do smth
                                // kick the user out, they shouldnt be here
                                print("Failed to retrieve symmetric key")
                            }
                        }
                        showAddAccountSheet = false
                    }
                }
            }, label: {
                Text("Add Account")
            })
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}
