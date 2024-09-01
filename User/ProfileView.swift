//
//  ProfileView.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 8/8/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import FirebaseStorage

struct ProfileView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    @State var data: Data?
    @State var selectedItem: [PhotosPickerItem] = []
    @State var dirty: Bool = false
    var body: some View {
        if let userData = userViewModel.userData {
            NavigationStack{
                
                VStack {
                    
                    Spacer()
                    
                    if dirty == false {
                        AsyncImage(url: URL(string: userData.profileImageUrl ?? "")) { phase in
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
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedItem, maxSelectionCount: 1, selectionBehavior: .default, matching: .images, preferredItemEncoding: .automatic) {
                        if let data = data, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 200, height: 200)
                        } else {
                            Label("Select a picture", systemImage: "photo.on.rectangle.angled").foregroundColor(Color.purple)
                        }
                            
                    }
                    
                    .onChange(of: selectedItem) { _ in
                        dirty = true
                        guard let item = selectedItem.first else { return }
                        item.loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    self.data = data
                                }
                            case .failure(let failure):
                                print("Error: \(failure.localizedDescription)")
                            }
                        }
                    }
                    
                    HStack {
                        Text("Name: ").bold()
                        Spacer()
                        Text(userData.name ?? "User Data").bold()
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Text("Email: ").bold()
                        Spacer()
                        Text(userData.email ?? "No Email").bold()
                    }
                    .padding()
                    
                    Spacer()
                    
                    List{

                        NavigationLink("Friends") {
                            FriendsView()
                        }.listRowSeparatorTint(.purple).font(.subheadline).bold()
                        NavigationLink("Settings") {
                            SettingsView()
                        }.listRowSeparatorTint(.purple).font(.subheadline).bold()
                    }
                    .listStyle(.inset)
                    
                    
                    Spacer()
                     
                    HStack {
                        
                        Spacer()
                        
                        Button(action: {
                            do {
                                try userViewModel.resetUserData()
                            } catch {
                                print(error)
                            }
                        }, label: {
                            Text("Log Out")
                        })
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .controlSize(.regular)
                        
                        Spacer()
                        
                        Button("Save Profile") {
                            guard let imageData = data else { return }
                            Task {
                                await userViewModel.uploadProfilePicture(imageData: imageData)
                            }
                            isPresented = false
                            dirty = false
                        }
                        
                        .disabled(data == nil)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .controlSize(.regular)
                        
                        Spacer()
                        
                    }.padding()
                }
                .onAppear {
                    Task {
                        await userViewModel.fetchUserData()
                    }
                }
                .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Profile")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.red, .blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .padding(.horizontal)
                            }
                        }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
