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
    @State private var showSheet: Bool = false
    func addAccount() {
        //
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let name = userViewModel.userData?.name {
                    Text("Welcome to Gatekeeper Manager, \(name)!")
                } else {
                    Text("Welcome to Gatekeeper Manager!")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSheet.toggle()
                          }) {
                          Label("Add Account", systemImage: "plus.app.fill")
                                  .padding()
                                  .cornerRadius(5)
                          }
                          .sheet(isPresented: $showSheet) {
                              AccountView().presentationDetents([.fraction(0.25)])
                          }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print(error)
                        }
                    }, label: {
                        Text("Log Out")
                    })
                }
            }
            .onAppear {
                Task {
                    await userViewModel.fetchUserData()
                }
            }
        }
        
    }
}

//#Preview {
//    HomeView()
//}
