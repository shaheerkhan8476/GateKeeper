//
//  AccountItemDetailView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/6/24.
//
import SwiftUI

struct AccountItemDetailView: View {
    let account: Account
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @State var name: String
    @State  var password: String
    @State var price: String
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Account Name:")
                    .font(.headline)
            }
            TextField("Enter account name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Text("Account Password:")
                    .font(.headline)
            }
            SecureField("Enter account password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            HStack {
                Text("Monthly Price: ")
                    .font(.headline)
            }
            TextField("Enter Subscription Price: ", text: $price)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    if let key = userViewModel.retrieveSymmetricKey() {
                        
                        if let encryptedPasswordData = userViewModel.encryptData(sensitive: password, key: key) {
                            account.name = name
                            account.password = encryptedPasswordData.base64EncodedString()
                            account.price = Double(price) ?? account.price
                            await userViewModel.editAccount(account: account)
                        } else {
                            print("Failed to encrypt password")
                        }
                    } else {
                        print("Failed to retrieve symmetric key")
                    }
                    await MainActor.run {
                        dismiss()
                    }
                }
            }, label: {
                Text("Save Account")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            .padding()
        }
        .padding()
        .navigationTitle("Account Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
