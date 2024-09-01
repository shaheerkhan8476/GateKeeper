//
//  AddFriendView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/1/24.
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @Binding var showAddSheet: Bool
    @State var friendEmail: String = ""
    var body: some View {
        VStack {
            TextField("Enter Friend's Email", text: $friendEmail)
            Divider()
            Button {
               
                Task {
                    do {
                        try await friendsViewModel.addFriend(friend: friendEmail)
                        showAddSheet.toggle()
                    } catch {
                        print(error)
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
