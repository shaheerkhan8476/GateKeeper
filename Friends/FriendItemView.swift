//
//  FriendItemView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/2/24.
//

import SwiftUI


struct FriendItemView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    let friend: Friend
    var body: some View {
        NavigationLink(destination: FriendItemDetailView(friend: friend)) {
            HStack {
                Text(friend.name)
            }
        }
    }
}

