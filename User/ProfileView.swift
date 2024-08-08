//
//  ProfileView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/8/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        if let userData = userViewModel.userData {
            VStack {
                Text(userData.name ?? "User Data").bold()
                Divider()
                Text(userData.email ?? "No Email").bold()
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}
