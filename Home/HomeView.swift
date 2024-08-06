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
    @State private var showSheet = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Accounts").bold()
            }
            Spacer()
            VStack {
                AccountView()
            }
            Spacer()
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
                            AddAccountView(showAddAccountSheet: $showSheet)
                                .presentationDetents([.fraction(0.25)])
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                userViewModel.resetUserData()
                            } catch {
                                print(error)
                            }
                        }, label: {
                            Text("Log Out")
                        })
                    }
                }
            }.onAppear {
                Task {
                    await userViewModel.fetchUserData()
                }
            }
            
        }
    }

