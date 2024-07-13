//
//  ContentView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/8/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore


struct ContentView: View {
    
    @State private var loggedIn: Bool = false
    
    var body: some View {
        VStack{
            if loggedIn {
                HomeView()
            }
            else {
                
                LogInView()
                
            }
            
        }
        .onAppear{Auth.auth().addStateDidChangeListener { auth, user in
            if auth.currentUser == nil {
                print("Not logged in")
                loggedIn = false
            }
            else {
                loggedIn = true
            }
        }}
        
    }
}


#Preview {
    ContentView()
}
