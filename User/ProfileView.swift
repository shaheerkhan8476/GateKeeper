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
                ZStack(alignment: .bottomTrailing){
                            Image(systemName: "heart.circle.fill")
                                 .resizable()
                                 .frame(width:100, height: 100)
                                 .clipShape(Circle())
                            Image(systemName: "plus.circle")
                                 .foregroundColor(.white)
                                 .frame(width: 25, height: 25)
                                 .background(Color.blue)
                                 .clipShape(Circle())
                               
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                .padding()
                Spacer()
                HStack{
                    Text("Name: ").bold()
                    Spacer()
                    Text(userData.name ?? "User Data").bold()
                }.padding()
                Divider()
                HStack {
                    Text("Email: ").bold()
                    Spacer()
                    Text(userData.email ?? "No Email").bold()
                }.padding()
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
