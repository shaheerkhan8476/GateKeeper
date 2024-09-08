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
        Spacer()
        VStack {
            if friend.profileImageUrl != "" {
                
                AsyncImage(url: URL(string: friend.profileImageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    @unknown default:
                        EmptyView()
                    }
                }
                    
            }
            
            HStack {
                Text("Name: ").font(.headline)
                Spacer()
                Text(friend.name)
                    .font(.headline)
            }
            Divider()
            HStack{
                Text("Email: ").font(.headline)
                Spacer()
                Text(friend.email)
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
    }
}

