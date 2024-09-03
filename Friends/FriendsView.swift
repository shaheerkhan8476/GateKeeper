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
//                        FriendItemView(friend: friend)
                        HStack {
                            Text(friend.name)
                            Text(friend.email)
                        }
                            .listRowSeparatorTint(.purple)
                    }
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showAddSheet.toggle()
                            
                        }) {
                            Label("Add Friend", systemImage: "plus.app.fill")
                                .padding()
                                .cornerRadius(5)
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
