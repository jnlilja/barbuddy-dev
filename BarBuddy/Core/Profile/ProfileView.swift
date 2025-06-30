//
//  BarBuddyUITests.swift
//  BarBuddyUITests
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var selectedImage: String? = nil
    @State private var isImageExpanded: Bool = false
    @State private var isSearchActive: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var userFriends = UserFriends.shared
    @State private var showSignOutAlert: Bool = false
    
    @Namespace var animation
    
    private var screenWidth: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
    }
    
    private var gridCellWidth: CGFloat {
        let padding = CGFloat(16 * 2 + 15 * 2)
        return (screenWidth - padding) / 3
    }
    
    var body: some View {
        NavigationStack {
            //GeometryReader { geometry in
                ZStack {
                    Color.darkBlue
                        .ignoresSafeArea()
                    // ─── Main profile + tabs + content ───
                    VStack(spacing: 25) {
                        // Profile header
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.white)
                                .padding(.leading)
                                .hidden()
                            
                            Spacer()
                            
                            Group {
                                if let username = authVM.currentUser?.username {
                                    Text("\(username)")
                                } else {
                                    Text("Log In Or Create an Account")
                                }
                            }
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.nude)
                            .padding()
                            .background(.salmon.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(.white)
                                    .padding(.trailing)
                            }
                        }
                        
                        Group {
                            if let pic = authVM.currentUser?.profile_pictures.first, let url = URL(string: pic) {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            .white,
                                            lineWidth: 4
                                        )
                                    )
                                    .overlay(alignment: .bottomTrailing) {
                                        Button {
                                            // TODO: Add action for editing profile picture
                                            print("Edit profile picture tapped")
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 32, height: 32)
                                                .background(Color.salmon)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                                .shadow(radius: 2)
                                        }
                                        .offset(x: 5, y: 5) // Adjust offset to position on the rim
                                    }
                                    .shadow(radius: 7)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        if let user = authVM.currentUser {
                            Text("\(user.first_name) \(user.last_name)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            ProfileTabView(selection: $selectedTab)
                        } else {
                            Text("Guest")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            Text("Sign in to access your profile and features.")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        
                        // Tab content
                        switch selectedTab {
                        case 0:
                            // Photos grid
                            LazyVGrid(columns: [
                                GridItem(.fixed(gridCellWidth), spacing: 15),
                                GridItem(.fixed(gridCellWidth), spacing: 15),
                                GridItem(.fixed(gridCellWidth))
                            ], spacing: 15) {
                                if let user = authVM.currentUser {
                                    ForEach(user.profile_pictures.sorted(), id: \.self) { img in
                                        ZStack(alignment: .topTrailing) {
                                            if let url = URL(string: img) {
                                                WebImage(url: url)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: gridCellWidth, height: gridCellWidth)
                                                    .clipped()
                                                    .cornerRadius(10)
                                                    .onTapGesture {
                                                        selectedImage = img
                                                        isImageExpanded = true
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                        case 1:
                            // Info sections
                            HStack {
                                VStack(alignment: .leading, spacing: 20) {
                                    if let user = authVM.currentUser {
                                        InfoSection(title: "Basic Info", items: [
                                            InfoItem(icon: "calendar",         text: user.date_of_birth ?? ""),
                                            InfoItem(icon: "mappin.circle.fill", text: user.hometown ?? "")
                                        ])
                                        InfoSection(title: "Work & Education", items: [
                                            InfoItem(icon: "graduationcap.fill", text: user.job_or_university ?? "")
                                        ])
                                        InfoSection(title: "Preferences", items: [
                                            InfoItem(icon: "wineglass.fill",      text: user.favorite_drink ?? ""),
                                            InfoItem(icon: "person.2.fill",      text: user.sexual_preference ?? "")
                                        ])
                                    }
                                }
                                .padding(.horizontal, 16)
                                
                                Spacer()
                            }
                            
                        case 2:
                            // Friends list
                            if userFriends.friends.isEmpty {
                                HStack {
                                    Image(systemName: "person.3")
                                        .padding(.trailing)
                                    Text("Looking for friends?\nGet started here!")
                                }
                                .font(.title3)
                                .foregroundColor(.white)
                            } else {
                                ForEach(userFriends.friends) { friend in
                                    NavigationLink(destination: FriendProfile(user: friend)) {
                                        FriendRow(friend: friend)
                                    }
                                }
                            }
                        default:
                            SettingsView()
                        }
                        
                        Spacer()
                        
                    }
                    .tint(.salmon)
                }
        }
    }
}

// ───────── Helper Views ─────────

struct FriendRow: View {
    let friend: GetUser
    var body: some View {
        HStack {
            Image(friend.profile_pictures.first ?? "")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("\(friend.first_name) \(friend.last_name)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(friend.hometown ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 10)
                .cornerRadius(25)
                .contentShape(RoundedRectangle(cornerRadius: 25)) // Increases hit area for taps
        }
        .buttonStyle(.plain)
    }
}

struct InfoSection: View {
    let title: String
    let items: [InfoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            ForEach(items) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(Color("Salmon"))
                    Text(item.text)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InfoItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

//uncomment block to see how profile looks
#Preview {
    ProfileView()
        .environmentObject(
            {
                // build & seed your AuthViewModel in one expression
                let vm = AuthViewModel()
                vm.currentUser = GetUser(
                    id: 1,
                    username: "andbet",
                    first_name: "Andrew",
                    last_name: "Betancourt",
                    date_of_birth: "August 5, 2000",
                    email: "andbet@example.com",
                    password: "",
                    hometown: "San Diego",
                    job_or_university: "iOS Developer",
                    favorite_drink: "Mango Cart",
                    location: "Springfield",
                    profile_pictures: ["https://media.licdn.com/dms/image/v2/D5603AQESXCm3P4ILfQ/profile-displayphoto-shrink_200_200/B56ZbfdaHjHgAc-/0/1747505752088?e=1756339200&v=beta&t=-dU2s68DPmp55HxWFCBiT3GZD8FtoLkw76LiV3AsETQ"],
                    matches: [],
                    swipes: [],
                    vote_weight: 0,
                    account_type: "regular",
                    sexual_preference: "Straight"
                )
                return vm
            }()
        )
}
#Preview("No User") {
    @Previewable @StateObject var authVM = AuthViewModel()
    ProfileView()
        .environmentObject(authVM)
}
