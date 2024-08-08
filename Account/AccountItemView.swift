//
//  AccountItemView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/20/24.
//
import SwiftUI

struct AccountItemView: View {
    let account: Account
    @State private var isSecured: Bool = true
    
    var body: some View {
        NavigationLink(destination: AccountItemDetailView(account: account, name: account.name, password: account.password)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(account.name)
                        .font(.headline)
                    Spacer()
                    if isSecured {
                        SecureField("Password", text: .constant(account.password))
                            .disabled(true)
                    } else {
                        Text(account.password)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "lock.fill" : "lock.open.fill")
                        .padding()
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
        }
    }
}
