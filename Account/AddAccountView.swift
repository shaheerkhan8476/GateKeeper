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
                    Task {
                        // Retrieve the symmetric key
                        if let key = userViewModel.retrieveSymmetricKey() {
                            // Encrypt the account password
                            if let encryptedPasswordData = userViewModel.encryptData(sensitive: accountPassword, key: key) {
                                // Create a new account with the encrypted password
                                let encryptedPasswordString = encryptedPasswordData.base64EncodedString()
                                let newAccount = Account(name: accountName, password: encryptedPasswordString)
                                
                                // Add the account
                                await userViewModel.addAccount(account: newAccount)
                            } else {
                                print("Failed to encrypt password")
                            }
                        } else {
                            print("Failed to retrieve symmetric key")
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
