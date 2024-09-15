//
//  AddAccountView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/15/24.
//
import SwiftUI

struct AddAccountView: View {
    @Environment (\.dismiss) var dismiss
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
                            // Encrypt the account password
                            if let encryptedPasswordData = accountViewModel.encryptData(sensitive: accountPassword, key: key) {
                                
                                let encryptedPasswordString = encryptedPasswordData.base64EncodedString()
                                let newAccount = Account(name: accountName, password: encryptedPasswordString, price: Double(accountPrice) ?? 0.0)
                               
                                await accountViewModel.addAccount(account: newAccount)
                                await accountViewModel.getAccountData(key: key)
                            } else {
                                print("Failed to encrypt password")
                            }
                        case .failure(let error):
                            switch error {
                            case .notLoggedIn:
                                print("Failed to retrieve symmetric key")
                            }
                        }
                        dismiss()
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
