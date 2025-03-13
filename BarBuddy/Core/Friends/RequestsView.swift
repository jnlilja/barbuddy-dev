import SwiftUI

struct RequestsView: View {
    @State private var friendRequests: [User] = MockDatabase.getFriends()
    @State private var selectedUser: User? = nil
    @State private var isShowingProfile: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(friendRequests) { user in
                    HStack {
                        // Card area that navigates to FriendProfile when tapped.
                        HStack(spacing: 8) {
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
                        .frame(maxWidth: 250, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedUser = user
                            isShowingProfile = true
                        }

                        Spacer()

                        // Accept button
                        Button(action: {
                            // Accept friend request
                            UserFriends.shared.addFriend(user)
                            // Remove from friendRequests
                            if let index = friendRequests.firstIndex(where: { $0.id == user.id }) {
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
            }
            .navigationTitle("Friend Requests")
            
            // Hidden NavigationLink
            .background(
                NavigationLink(
                    destination: Group {
                        // If selectedUser is non‐nil, show FriendProfile; otherwise EmptyView.
                        if let user = selectedUser {
                            FriendProfile(user: user)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $isShowingProfile
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}

struct RequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestsView()
    }
}
