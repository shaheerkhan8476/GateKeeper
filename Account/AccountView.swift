//
//  AccountView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/18/24.
//
import SwiftUI
import Foundation
import CryptoKit
struct AccountView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        let accounts: [Account] = accountViewModel.accountData
        VStack {
            List {  
                ForEach(accounts) { account in
                    AccountItemView(account: account)
                        .listRowSeparatorTint(.purple)
                }
                .onDelete { account in
                    Task {
                        await deleteAccounts(at: account, from: accounts)
                        switch userViewModel.retrieveSymmetricKey() {
                        case .success(let key):
                            await accountViewModel.getAccountData(key: key)
                        
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .padding()
        }
        .onAppear {
            Task {
                switch userViewModel.retrieveSymmetricKey() {
                case .success(let key):
                    print("Received Key")
                    await accountViewModel.getAccountData(key: key)
                case .failure(let error):
                    print("\(error)")
                }
            }
        }
    }
    
    private func deleteAccounts(at offsets: IndexSet, from accounts: [Account]) async {
        for index in offsets {
            let account = accounts[index]
            await accountViewModel.deleteAccount(account: account)
        }
    }
}
