//
//  BarBuddyUITests.swift
//  BarBuddyUITests
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: SessionManager
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var selectedImage: String? = nil
    @State private var isImageExpanded: Bool = false
    @State private var isSearchActive: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var userFriends = UserFriends.shared

    private var gridCellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding = CGFloat(16 * 2 + 15 * 2)
        return (screenWidth - padding) / 3
    }

    private var filteredFriends: [GetUser] {
        guard !searchText.isEmpty else { return userFriends.friends }
        let q = searchText.lowercased()
        let first = userFriends.friends.filter { $0.first_name.lowercased().contains(q) }
        let last  = userFriends.friends.filter {
            !$0.first_name.lowercased().contains(q) &&
            $0.last_name.lowercased().contains(q)
        }
        return first + last
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                // ─── Main profile + tabs + content ───
                if let user = authVM.currentUser {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Profile header
                            Group {
                                if let key = user.profile_pictures?.keys.first,
                                   let pic = user.profile_pictures?[key] {
                                    Image(pic)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 7)
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                }
                            }
                            .padding(.top, 20)

                            HStack(spacing: 8) {
                                Text("\(user.first_name) \(user.last_name)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color("NeonPink"))
                                    .font(.system(size: 24))
                            }

                            // Tabs
                            HStack(spacing: 0) {
                                TabButton(text: "Photos", isSelected: selectedTab == 0) { selectedTab = 0 }
                                TabButton(text: "Info",    isSelected: selectedTab == 1) { selectedTab = 1 }
                                TabButton(text: "Friends", isSelected: selectedTab == 2) { selectedTab = 2 }
                                TabButton(text: "Settings", isSelected: selectedTab == 3) { selectedTab = 3 }
                            }
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(25)
                            .padding(.horizontal)
                            .padding(.top, 20)

                            // Tab content
                            switch selectedTab {
                            case 0:
                                // Photos grid
                                LazyVGrid(columns: [
                                    GridItem(.fixed(gridCellWidth), spacing: 15),
                                    GridItem(.fixed(gridCellWidth), spacing: 15),
                                    GridItem(.fixed(gridCellWidth))
                                ], spacing: 15) {
                                    ForEach(user.profile_pictures?.values.sorted() ?? [], id: \.self) { img in
                                        ZStack(alignment: .topTrailing) {
                                            Image(img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: gridCellWidth, height: gridCellWidth)
                                                .clipped()
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    selectedImage = img
                                                    isImageExpanded = true
                                                }
                                            Button {
                                                // edit
                                            } label: {
                                                Circle()
                                                    .fill(Color("Salmon"))
                                                    .frame(width: 30, height: 30)
                                                    .overlay(
                                                        Image(systemName: "pencil")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.white)
                                                    )
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)

                            case 1:
                                // Info sections
                                VStack(alignment: .leading, spacing: 20) {
                                    InfoSection(title: "Basic Info", items: [
                                        InfoItem(icon: "calendar",         text: user.date_of_birth),
                                        InfoItem(icon: "mappin.circle.fill", text: user.hometown)
                                    ])
                                    InfoSection(title: "Work & Education", items: [
                                        InfoItem(icon: "graduationcap.fill", text: user.job_or_university)
                                    ])
                                    InfoSection(title: "Preferences", items: [
                                        InfoItem(icon: "wineglass.fill",      text: user.favorite_drink),
                                        InfoItem(icon: "person.2.fill",      text: user.sexual_preference)
                                    ])
                                }
                                .padding(.horizontal, 16)

                            case 2:
                                // Friends list
                                if userFriends.friends.isEmpty {
                                    Text("No friends yet.")
                                        .foregroundColor(.white)
                                        .padding()
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
                        }
                        .padding(.bottom, 20)
                        .onTapGesture { isSearchFieldFocused = false }
                    }
                    .fullScreenCover(isPresented: $isImageExpanded) {
                        if let img = selectedImage {
                            ZStack {
                                Color.black.ignoresSafeArea()
                                Image(img)
                                    .resizable()
                                    .scaledToFit()
                                    .onTapGesture { isImageExpanded = false }
                            }
                        }
                    }
                    .task { await userFriends.loadFriends() }
                }

                // ─── Sliding friend‑search overlay ───
                VStack(spacing: 0) {
                    HStack {
                        TextField("Search Friends", text: $searchText)
                            .focused($isSearchFieldFocused)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        Button("Cancel") {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isSearchActive = false
                                searchText = ""
                                isSearchFieldFocused = false
                            }
                        }
                        .foregroundColor(Color("Salmon"))
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .background(Color("DarkBlue"))

                    List(filteredFriends) { friend in
                        NavigationLink(destination: FriendProfile(user: friend)) {
                            Text("\(friend.first_name) \(friend.last_name)")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color("DarkBlue"))
                    }
                    .listStyle(PlainListStyle())
                }
                .background(Color("DarkBlue").ignoresSafeArea())
                .offset(y: isSearchActive ? 0 : UIScreen.main.bounds.height)
                .animation(.easeInOut(duration: 0.25), value: isSearchActive)
                .zIndex(1)
            }
            .toolbar {
                // Temporary signout view
                ToolbarItem(placement: .navigation) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: RequestsView()) {
                        Label("Friend Requests", systemImage: "person.crop.circle.badge.plus")
                    }
                    .tint(Color("Salmon"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { isSearchActive = true }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .tint(Color("Salmon"))
                }
            }
        }
        .tint(Color("Salmon")) // ← Apply Salmon tint to back button
    }
}

// ───────── Helper Views ─────────

struct FriendRow: View {
    let friend: GetUser
    var body: some View {
        HStack {
            Image(friend.profile_pictures?.values.first ?? "")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("\(friend.first_name) \(friend.last_name)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(friend.hometown)
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
                .frame(width: 100, height: 40)
                .background(isSelected ? Color("Salmon") : Color.clear)
                .cornerRadius(25)
        }
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



//uncomment for real user data
/*#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}*/

//uncomment block to see how profile looks
#Preview {
    ProfileView()
      .environmentObject({
          // build & seed your AuthViewModel in one expression
          let vm = SessionManager()
          vm.currentUser = GetUser(
            id: 1,
            username: "jdoe",
            first_name: "John",
            last_name: "Doe",
            email: "jdoe@example.com",
            password: "",
            date_of_birth: "1990-01-01",
            hometown: "Springfield",
            job_or_university: "Example U",
            favorite_drink: "Coffee",
            location: "Springfield",
            profile_pictures: ["pic1":"TestImage"],
            matches: "",
            swipes: "",
            vote_weight: 0,
            account_type: "regular",
            sexual_preference: "straight"
          )
          return vm
      }())
}
