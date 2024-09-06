//
//  FriendsView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/1/24.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @State var showAddSheet: Bool = false
    private func deleteAccounts(at offsets: IndexSet, from friends: [Friend]) async {
        for index in offsets {
            let friend = friends[index]
            await friendsViewModel.deleteFriend(friend: friend)
        }
    }

    var body: some View {
        
        let friends = friendsViewModel.friendData
        NavigationStack{
            VStack(alignment: .leading, spacing: 0) {
                Text("Friends List")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal)
                List {
                    ForEach(friendsViewModel.friendData, id: \.email) { friend in
                        FriendItemView(friend: friend)
                            .listRowSeparatorTint(.purple)
                    }
                    .onDelete { friend in
                        Task {
                            await deleteAccounts(at: friend, from: friends)
                        }
                    }
                }
                .listStyle(.inset)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showAddSheet.toggle()
                            
                        }) {
                            Label("Add Friend", systemImage: "plus.app.fill")
                                .padding()
                                .cornerRadius(5)
                                .tint(.purple)
                        }
                        .sheet(isPresented: $showAddSheet) {
                            AddFriendView(showAddSheet: $showAddSheet)
                                .presentationDetents([.fraction(0.40)])
                        }
                    }
                }
            }
        }
        .onAppear() {
            Task {
                try await friendsViewModel.getFriends()
            }
        }
    }
}
