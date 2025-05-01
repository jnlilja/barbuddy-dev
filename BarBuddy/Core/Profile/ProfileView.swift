//
//  BarBuddyUITests.swift
//  BarBuddyUITests
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var selectedImage: String?
    @State private var isImageExpanded: Bool = false
    @State private var isSearchActive: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var userFriends = UserFriends.shared

    private var gridCellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding = CGFloat(16 * 2 + 15 * 2)
        return (screenWidth - padding) / 3
    }

    private var filteredFriends: [User] {
        guard !searchText.isEmpty else { return userFriends.friends }
        let q = searchText.lowercased()
        let first = userFriends.friends.filter { $0.firstName.lowercased().contains(q) }
        let last  = userFriends.friends.filter {
            !$0.firstName.lowercased().contains(q) &&
            $0.lastName.lowercased().contains(q)
        }
        return first + last
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                // ─── Main profile + tabs + content ───
                if let user = authVM.currentUser {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Profile header
                            Group {
                                if !user.profilePictures[0].image.isEmpty {
                                    WebImage(url: URL(string: user.profilePictures[0].image))
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
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color("NeonPink"))
                                    .font(.system(size: 24))
                            }

                            // Tabs
                            ProfileTabsView { selectedTab in
                                // MARK: Photos
                               if selectedTab == 0 {
                                   LazyVGrid(columns: [
                                       GridItem(.fixed(gridCellWidth), spacing: 15),
                                       GridItem(.fixed(gridCellWidth), spacing: 15),
                                       GridItem(.fixed(gridCellWidth))
                                   ], spacing: 15) {
                                       if !user.profilePictures[0].image.isEmpty {
                                           //ForEach(profilePictures.filter { !$0.isPrimary }, id: \.self) { image in
                                               ZStack(alignment: .topTrailing) {
                                                   WebImage(url: URL(string: user.profilePictures[0].image)) { image in
                                                       image.resizable()
                                                           
                                                   } placeholder: {
                                                       RoundedRectangle(cornerRadius: 10)
                                                   }
                                                   .scaledToFill()
                                                   .frame(width: gridCellWidth, height: gridCellWidth)
                                                   .clipped()
                                                   .cornerRadius(10)
                                                   .onTapGesture {
                                                       selectedImage = user.profilePictures[0].image
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
                                           //}
                                       }
                                   }
                                   .padding(.horizontal, 16)
                                }
                                // MARK: User's Info
                                else if selectedTab == 1 {
                                    // Info sections
                                    VStack(alignment: .leading, spacing: 20) {
                                        InfoSection(title: "Basic Info", items: [
                                            InfoItem(icon: "calendar",         text: user.dateOfBirth ?? ""),
                                            InfoItem(icon: "mappin.circle.fill", text: user.hometown)
                                        ])
                                        InfoSection(title: "Work & Education", items: [
                                            InfoItem(icon: "graduationcap.fill", text: user.jobOrUniversity)
                                        ])
                                        InfoSection(title: "Preferences", items: [
                                            InfoItem(icon: "wineglass.fill",      text: user.favoriteDrink),
                                            InfoItem(icon: "person.2.fill",      text: user.sexualPreference ?? "")
                                        ])
                                    }
                                    .padding(.horizontal, 16)
                                }
                                else if selectedTab == 2 {
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
                                }
                                else {
                                    SettingsView()
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        .onTapGesture { isSearchFieldFocused = false }
                    }
                    .onChange(of: selectedImage) {
                        // Somehow this fixed the image problem
                        // in the fullScreenCover by adding this modifier 🤷🏻‍♂️
                    }
                    .fullScreenCover(isPresented: $isImageExpanded) {
                        if let img = selectedImage {
                            ZStack {
                                Color.black.ignoresSafeArea()
                                WebImage(url: URL(string: img))
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
                            Text("\(friend.firstName) \(friend.lastName)")
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
                    .tint(.salmon)
                }
            }
        }
        .tint(.salmon) // ← Apply Salmon tint to back button
    }
}

// ───────── Helper Views ─────────

struct FriendRow: View {
    let friend: User
    var body: some View {
        HStack {
            Image(friend.profilePictures[0].image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("\(friend.firstName) \(friend.lastName)")
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
                    Spacer()
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
#Preview("User Data") {
    ProfileView()
        .environmentObject(AuthViewModel())
}

//uncomment block to see how profile looks
#Preview("Example"){
    ProfileView()
      .environmentObject({
          // build & seed your AuthViewModel in one expression
          let vm = AuthViewModel()
//          let dummyPic = "https://media.istockphoto.com/id/1388645967/photo/pensive-thoughtful-contemplating-caucasian-young-man-thinking-about-future-planning-new.jpg?s=612x612&w=0&k=20&c=Keax_Or9RivnYV_9VoOLjknWQP8iaxYXc4jS9rwBmcc="
//          let dummyPic2 = "https://media.istockphoto.com/id/1550540247/photo/decision-thinking-and-asian-man-in-studio-with-glasses-questions-and-brainstorming-on-grey.jpg?s=612x612&w=0&k=20&c=u0axNDq0EuPp8cEjR5mmVOaAt4FvRCTnbD4SQt66WTw="
//          let dummyPic3 = "https://plus.unsplash.com/premium_photo-1683121541367-eeb807eddb03?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGJlZXJ8ZW58MHx8MHx8fDA%3D"
          vm.currentUser = User(
            id: 1,
            username: "jdoe",
            firstName: "John",
            lastName: "Doe",
            email: "jdoe@example.com",
            password: "",
            dateOfBirth: "1990-01-01",
            hometown: "Springfield",
            jobOrUniversity: "Example U",
            favoriteDrink: "Coffee",
            location: "Location(latitude: 20, longitude: 20)",
            profilePictures: [ProfilePictures(id: 9, image: "", isPrimary: true, uploadedAt: "")],
            matches: [Match(id: 0, user1: 1, user1Details: MatchUser(id: 0, username: "", profilePicture: ""), user2: 4, user2Details: MatchUser(id: 1, username: "", profilePicture: ""), status: "", createdAt: "", disconnectedBy: 7, disconnectedByUsername: "")],
            swipes: [Swipe(id: 0, swiperUsername: "", swipedOn: 1, status: "", timestamp: "")],
            voteWeight: 0,
            accountType: "regular",
            sexualPreference: "straight",
            phoneNumber: ""
          )
          return vm
      }())
}
