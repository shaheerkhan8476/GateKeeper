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
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State private var showSheet = false
    @State private var showUserSheet = false
    @State private var accountsEmpty: Bool = false;
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your Accounts")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal)
                
                
                if accountViewModel.isEmpty{
                    VStack {
                        Spacer() // Push content down
                        Text("Add an Account!")
                            .padding()
                            .fontWeight(.bold)
                            .font(.subheadline)
                        Spacer() // Push content up
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the text stays in the center horizontally
                }
                else {
                    AccountView()
                }
                
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showUserSheet.toggle()
                    }) {
                        Label("User Profile", systemImage: "person.circle.fill")
                    }
                    .sheet(isPresented: $showUserSheet) {
                        ProfileView(isPresented: $showUserSheet)
                            .presentationDetents([.fraction(1)])
                    }
                }
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
                            .presentationDetents([.fraction(0.40)])
                            .onDisappear {
                                    if !accountViewModel.accountData.isEmpty {
                                        accountsEmpty = false
                                    }
                            }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("Total Monthly Cost: $\(accountViewModel.totalPrice, specifier: "%.2f")")
                            .foregroundColor(.green)
                            .font(.subheadline.bold())
                    }
                }
            }
            
            .onAppear {
                Task {
                    await userViewModel.fetchUserData()
                    switch userViewModel.retrieveSymmetricKey() {
                    case .success(let key):
                        await accountViewModel.getAccountData(key: key)
                    case.failure(let error):
                        print(error)
                        break
                    }
                }
                
            }
            
        }
    }
}

