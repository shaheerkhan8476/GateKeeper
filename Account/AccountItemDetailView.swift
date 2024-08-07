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
    var body: some View {
        VStack{
            TextField(account.name, text: $name)
            Text(account.password)
        }
        Button(action: {
            let new_account = Account(name: name, password: account.password)
                Task {
                    await userViewModel.editAccount(account: new_account)
                    
                }
        }, label: {
            Text("Save Account")
        }).buttonStyle(.borderedProminent)
            .padding()
    }
        
}


