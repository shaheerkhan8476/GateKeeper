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
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(accounts) {account in
                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.headline)
                                    Text(account.password)
                                        .font(.subheadline)
                                }
                                .padding()
                                Divider()
                            }
                        }
                    }
                } else {
                    Text("Add an Account!")
                }
            }
        }
}

//#Preview {
//    AccountView()
//        .environmentObject(UserViewModel())
//}
