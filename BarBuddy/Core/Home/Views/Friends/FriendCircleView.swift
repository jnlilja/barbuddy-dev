import SwiftUI

// MARK: - Model
struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let occupation: String
    let profileImage: String
    let isOut: Bool  // true = "active", false = "inactive"
}

// MARK: - Friend Profile View (Placeholder)
struct FriendProfileView: View {
    let friend: Friend
    
    var body: some View {
        Text("Profile for \(friend.name)")
            .navigationTitle(friend.name)
    }
}

// MARK: - A new view to list potential friends
struct AddFriendsView: View {
    @StateObject private var viewModel = AddFriendsViewModel()
    
    var body: some View {
        VStack {
            Text("Add Friends")
                .font(.headline)
                .padding()
            
            List {
                // Potential friends section
                Section(header: Text("Suggested Friends")) {
                    ForEach(viewModel.potentialFriends) { friend in
                        HStack {
                            // Profile image
                            Image(friend.profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            // Name and occupation
                            VStack(alignment: .leading) {
                                Text(friend.name)
                                    .font(.headline)
                                Text(friend.occupation)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // "Add" button with action
                            Button("Add") {
                                viewModel.acceptFriend(friend)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("DarkPurple"))
                            .cornerRadius(16)
                        }
                    }
                }
                
                // Accepted friends section
                if !viewModel.acceptedFriends.isEmpty {
                    Section(header: Text("Added Friends")) {
                        ForEach(viewModel.acceptedFriends) { friend in
                            HStack {
                                Image(friend.profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(friend.name)
                                        .font(.headline)
                                    Text(friend.occupation)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("Added")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Friends")
    }
}

// MARK: - Main View
struct FriendCircleView: View {
    @StateObject private var addFriendsViewModel = AddFriendsViewModel()
    @State private var searchText = ""
    @State private var showAddFriendsView = false
    @State private var selectedFriendForMessage: Friend?
    @State private var showDirectMessage = false
    @State private var selectedFriendForProfile: Friend?
    @State private var showProfile = false
    
    // Example data
    let friends: [Friend] = [
        Friend(name: "Sarah Johnson",   occupation: "Software Engineer",  profileImage: "guy1", isOut: true),
        Friend(name: "Chris Martinez",  occupation: "Marketing Manager",  profileImage: "guy2", isOut: true),
        Friend(name: "Taylor Smith",    occupation: "UX Designer",        profileImage: "guy3", isOut: false),
        Friend(name: "Jordan Brown",    occupation: "Product Manager",    profileImage: "guy1", isOut: true),
        Friend(name: "Casey Wilson",    occupation: "Data Scientist",     profileImage: "guy2", isOut: false),
    ]
    
    // Sort active (isOut = true) before inactive
    private var sortedFriends: [Friend] {
        friends.sorted { $0.isOut && !$1.isOut }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Top bar + Title + new "Add Friends" icon
                HStack {
                    Text("Friends")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    
                    Spacer()
                    
                    // "Add Friends" icon
                    Button(action: {
                        showAddFriendsView = true
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(.darkBlue)
                    }
                }
                .padding()
                .background(Color.white)
                
                // Search bar directly under top bar
                ZStack {
                    Color.white
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for friends...", text: $searchText)
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .frame(height: 44)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Light purple background behind the list
                ZStack {
                    Color("LightPurple")
                        .ignoresSafeArea()
                    
                    List {
                        // Use sortedFriends here
                        ForEach(sortedFriends) { friend in
                            friendRow(friend)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
            // Navigation link to the new AddFriendsView
            .background(
                NavigationLink(
                    destination: AddFriendsView(),
                    isActive: $showAddFriendsView,
                    label: { EmptyView() }
                )
            )
            .background(
                NavigationLink(
                    destination: Group {
                        if let friend = selectedFriendForMessage {
                            DirectMessagingView(friend: friend)
                        }
                    },
                    isActive: $showDirectMessage,
                    label: { EmptyView() }
                )
            )
            .background(
                NavigationLink(
                    destination: Group {
                        if let friend = selectedFriendForProfile {
                            FriendProfileView(friend: friend)
                        }
                    },
                    isActive: $showProfile,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    // Helper view for a single friend row
    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 12) {
            // Profile section that navigates to profile when tapped
            Button(action: {
                selectedFriendForProfile = friend
                showProfile = true
            }) {
                HStack {
                    Image(friend.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(friend.name)
                            .font(.headline)
                        
                        // Show occupation
                        Text(friend.occupation)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Show "Active" in green or "Inactive" in gray
                        Text(friend.isOut ? "Active" : "Inactive")
                            .font(.subheadline)
                            .foregroundColor(friend.isOut ? .green : .gray)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Message button
            Button(action: {
                selectedFriendForMessage = friend
                showDirectMessage = true
            }) {
                Text("Message")
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("DarkPurple"))
                    .cornerRadius(16)
            }
            
            // Menu with remove option
            Menu {
                Button("Remove Friend", role: .destructive) {
                    // Remove friend action
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .listRowBackground(Color.clear)
    }
}

// MARK: - Preview
struct FriendCircleView_Previews: PreviewProvider {
    static var previews: some View {
        FriendCircleView()
    }
}
