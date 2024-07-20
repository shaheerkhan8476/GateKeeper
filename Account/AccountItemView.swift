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
        HStack{
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                Spacer()
                if isSecured {
                    SecureField("Password", text: .constant(account.password))
                } else {
                    Text(account.password)
                }
            }
            .padding()
            Spacer()
            Button {
              isSecured.toggle()
            } label: {
              Label("", systemImage: isSecured ? "lock.fill" : "lock.open.fill")
                .padding()
            }
        }
    }
}

//#Preview {
//    AccountItemView()
//}
