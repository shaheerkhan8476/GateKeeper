//
//  AddFriendView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/1/24.
//
import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @Environment (\.dismiss) var dismiss
    @State var friendEmail: String = ""
    @State private var errorMessage: String? = nil
    var body: some View {
        VStack {
            TextField("Enter Friend's Email", text: $friendEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            
            Divider()
            
            Button {
                Task {
                    do {
                        try await friendsViewModel.addFriend(friend: friendEmail)
                        dismiss()
                    } catch {
                        
                        guard let error = error as? FriendsViewModel.FriendsViewModelError else {
                            errorMessage = "unknown error"
                            return
                        }
                        if error == FriendsViewModel.FriendsViewModelError.cannotAddSelf {
                            errorMessage = "Cannot Add Yourself"
                        } 
                        else if error == FriendsViewModel.FriendsViewModelError.userNotFound {
                            errorMessage = "User Not Found"
                        }
                        else if error == FriendsViewModel.FriendsViewModelError.friendAlreadyExists {
                        errorMessage = "Friend is Already Added."
                        }
                        else {
                            errorMessage = "Unknown Error Occured"
                        }
                    }
                }
            } label: {
                Text("Add Friend")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}
