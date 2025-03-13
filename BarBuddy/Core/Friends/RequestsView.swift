//
//  RequestsView.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//  Modified to navigate to FriendProfile.

import SwiftUI

struct RequestsView: View {
    // Using only friends for demonstration.
    let friendRequests: [User] = MockDatabase.getFriends()

    var body: some View {
        List(friendRequests) { user in
            NavigationLink(destination: FriendProfile(user: user)) {
                HStack {
                    // Thumbnail image.
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
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Friend Requests")
    }
}

struct RequestsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RequestsView()
        }
    }
}
