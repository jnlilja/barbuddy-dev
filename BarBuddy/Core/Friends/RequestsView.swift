import SwiftUI

struct RequestsView: View {
    @State private var friendRequests: [User] = MockDatabase.getFriends()
    @State private var selectedUser: User? = nil

    var body: some View {
        NavigationStack {
            List(friendRequests) { user in
                HStack {
                    // Card area that navigates to FriendProfile when tapped.
                    HStack(spacing: 8) {
                        
                        Group {
                            Image(user.imageNames.first ?? "TestImage")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.hometown)
                                    .font(.subheadline)
                            }
                        }
                        .background {
                            // Hides arrow in the list
                            NavigationLink(value: user) {}
                                .opacity(0)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: 250, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedUser = user
                    }
                    // Accept button
                    Button(action: {
                        // Accept friend request
                        UserFriends.shared.addFriend(user)
                        // Remove from friendRequests
                        if let index = friendRequests.firstIndex(where: {
                            $0.id == user.id
                        }) {
                            friendRequests.remove(at: index)
                        }
                    }) {
                        Text("Accept")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("DarkPurple"))
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)

            }
            .navigationTitle("Friend Requests")
            .navigationDestination(item: $selectedUser) {
                FriendProfile(user: $0)
            }
        }
    }
}

#Preview {
    RequestsView()
}
