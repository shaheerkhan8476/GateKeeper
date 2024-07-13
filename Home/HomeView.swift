//
//  HomeView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/10/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    
    var body: some View {
        
        

        VStack{
            if let name = userViewModel.userData?.name {
                            Text("Welcome to Gatekeeper Manager, \(name)!")
                        } else {
                            Text("Welcome to Gatekeeper Manager!")
                        }
            Button(action: {
                do {
                    try Auth.auth().signOut()
                }
                catch {
                    print(error)
                }
            }, label: {
                Text("Log Out")
            })
        }
        .onAppear { Task{
            await userViewModel.fetchUserData()
        }
                }
    }
}

#Preview {
    HomeView()
}
