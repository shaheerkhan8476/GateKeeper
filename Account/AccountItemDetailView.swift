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
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var friendViewModel: FriendsViewModel
    @State var name: String
    @State  var password: String
    @State var price: String
    @State private var showAddUserSheet: Bool = false
    var body: some View {
        let authorizedUsers = account.authorizedUsers
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
            
            
            VStack {
                Text("Authorized Users").font(.headline)
                if account.authorizedUsers.isEmpty {
                    Text("Add Friends to Account!")
                }
                else {
                    List(authorizedUsers) { friend in
                        Text(friend.name)
                        .listRowSeparatorTint(.purple)
                    }
                    .listStyle(.inset)
                    .padding()
                }
                Button(action: {
                    showAddUserSheet.toggle()
                }) {
                    Label("Add User to Account", systemImage: "person.circle.fill")
                }
                .sheet(isPresented: $showAddUserSheet) {
                    AddUserSheetView(account: account)
                }
            }
            
            Spacer()
            Button(action: {
                Task {
                    switch userViewModel.retrieveSymmetricKey() {
                    case .success(let key):
                        if let encryptedPasswordData = accountViewModel.encryptData(sensitive: password, key: key) {
                            account.name = name
                            account.password = encryptedPasswordData.base64EncodedString()
                            account.price = Double(price) ?? account.price
                            await accountViewModel.editAccount(account: account)
                        } else {
                            print("Failed to encrypt password")
                        }
                    case .failure(_):
                        break
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
