//
//  ProfileView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/8/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        if let userData = userViewModel.userData {
            VStack {
                Spacer()
                HStack{
                    Text("Name: ").bold()
                    Spacer()
                    Text(userData.name ?? "User Data").bold()
                }
                Divider()
                HStack {
                    Text("Email: ").bold()
                    Spacer()
                    Text(userData.email ?? "No Email").bold()
                }
                Spacer()
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        userViewModel.resetUserData()
                    } catch {
                        print(error)
                    }
                }, label: {
                    Text("Log Out")
                }).padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}
