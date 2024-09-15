//
//  AddUserSheetView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/11/24.
//

import SwiftUI
struct AddUserSheetView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    let account: Account
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var friendViewModel: FriendsViewModel
    @State private var multiSelection: Set<Friend> = .init()
    
    var body: some View {
        NavigationStack {
            List(friendViewModel.friendData, id: \.self, selection: $multiSelection) { friend in
                Text(friend.name)
            }
            .navigationTitle("Friend List")
            .environment(\.editMode, .constant(.active))
        }
        .onAppear {
            multiSelection = Set(account.authorizedUsers)
            
            Task {
                try await friendViewModel.getFriends()
            }
            
            
        }
        Spacer()
        VStack {
            Button {
                Task {
                    await accountViewModel.addAuthorizedUsers(authorizedUsers: multiSelection, account: account)
                    dismiss()
                }
            } label: {
                if multiSelection.count > 1 {
                    Text("Add Friends")
                } else {
                    Text("Add Friend")
                }
            }
        }
        Spacer()
    }
}
