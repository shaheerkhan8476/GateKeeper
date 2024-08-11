//
//  AccountView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/18/24.
//

import SwiftUI
import Foundation


struct AccountView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
            VStack {
                if let accounts = userViewModel.userData?.accounts {
                    List {
                        ForEach(accounts) { account in
                           
                                AccountItemView(account: account)
                                .listRowSeparatorTint(.purple)
                            
                        }
                        .onDelete { account in
                            Task {
                                await deleteAccounts(at: account, from: accounts)
                                await userViewModel.fetchUserData()
                            }
                        }
                    }
                    .listStyle(.inset)
                    .padding()
                } else {
                    Text("Add an Account!")
                }
            }
        }
    private func deleteAccounts(at offsets: IndexSet, from accounts: [Account]) async {
            for index in offsets {
                let account = accounts[index]
                await userViewModel.deleteAccount(account: account)
            }
        }
}

