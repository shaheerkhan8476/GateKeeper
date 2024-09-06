//
//  FriendItemDetailView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 9/3/24.
//

import SwiftUI

struct FriendItemDetailView: View {
    let friend: Friend
    var body: some View {
        VStack {
            Text(friend.name)
                .font(.headline)
            Text(friend.email)
                .font(.headline)
        }
        .padding()
        
    }
}

