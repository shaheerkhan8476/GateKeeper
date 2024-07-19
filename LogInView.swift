//
//  LogInView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/11/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
struct LogInView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loggedIn: Bool = false
    @State private var name: String = ""
    let db = Firestore.firestore()
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        VStack{
            Text("Sign up for GateKeeper Manager").bold()
            Spacer()
            VStack {
                TextField("What is your Name?", text: $name)
                Divider()
                TextField("Enter Email", text: $email)
                Divider()
                SecureField("Enter Password", text: $password)
            }
            .padding()
            Spacer()
            VStack {
                Button(action: {
                    registerAccount()
                }, label: {
                    Text("Sign Up")
                }).buttonStyle(.borderedProminent)
                    .padding()
                Button(action: {
                    login()
                }, label: {
                    Text("Already have an account? Login!")
                }) .buttonStyle(.borderedProminent)
            }
            .padding()
            Spacer()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                loggedIn.toggle()
                Task {
                    loggedIn = true
                    await userViewModel.fetchUserData()
                }
            }
        }
    }
    
    func registerAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                var newUser: User = User(email: authResult?.user.email, id: authResult?.user.uid)
                let documentName = authResult?.user.uid ?? "No UID"
                Task{
                    do {
                        try await db.collection("users").document(documentName).setData([
                            "name": name,
                            "email": newUser.email,
                            "id": newUser.id,
                            "accounts": newUser.accounts
                        ])
                        print("Document successfully written!")
                    } catch {
                        print("Error writing document: \(error)")
                    }
                }
            }
        }
    }
    }

#Preview {
    LogInView()
}
