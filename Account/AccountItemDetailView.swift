//
//  AccountItemDetailView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/6/24.
//

import SwiftUI

struct AccountItemDetailView: View {
    let account: Account
    @EnvironmentObject var userViewModel: UserViewModel
    @State var name: String
    @State var password: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Account Name:")
                    .font(.headline)
            }
            TextField(account.name, text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Text("Account Password:")
                    .font(.headline)
               
            }
            SecureField(account.password, text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                account.name = name
                account.password = password
                Task {
                    await userViewModel.editAccount(account: account)
                }
            }, label: {
                Text("Save Account")
                    .buttonStyle(.borderedProminent)
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
