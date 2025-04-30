//
//  FriendProfile.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendProfile: View {
    let user: User
        @StateObject private var friendService = FriendService.shared

        var isFriend: Bool {
            friendService.friends.contains { $0.id == user.id }
        }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photo Gallery
                TabView {
                    //if let profilePictures = user.profilePictures {
                        //ForEach(profilePictures) {
                    WebImage(url: URL(string: user.profilePictures))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 457)
                                .clipped()
                        //}
                    //}
                }
                .frame(height: 457)
                .tabViewStyle(PageTabViewStyle())

                // Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("NeonPink"))
                            .font(.system(size: 20))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            Text(user.hometown)
                        }
                        .foregroundColor(Color("DarkPurple"))
                    }

                    Divider()

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(user.dateOfBirth ?? "None")
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                            Text(user.location.description)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("DarkPurple"))

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                            Text(user.jobOrUniversity)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "wineglass.fill")
                            Text(user.favoriteDrink)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                            Text(user.sexualPreference ?? "None")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("DarkPurple"))

                    // If you have a bio field, replace this:
                    Text("")
                        .font(.system(size: 24, weight: .light).italic())
                        .foregroundColor(Color("Salmon"))
                        .padding(.top, 12)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                if !isFriend {
                    Button("Add Friend") { Task { await friendService.sendFriendRequest(to: user) } }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("DarkPurple")) 
                        .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
//        let dummyImage = "https://media.istockphoto.com/id/2165337331/photo/portrait-of-tabby-cat.webp?a=1&b=1&s=612x612&w=0&k=20&c=_5WHcTO3VstFvHziQH3N7pGgbVnXEmXdN00NylUKgpo="
        FriendProfile(
            user: User(
                id: 1,
                username: "sampleuser",
                firstName: "Sample",
                lastName: "User",
                email: "sample@example.com",
                password: "password",
                dateOfBirth: "1990-01-01",
                hometown: "Springfield",
                jobOrUniversity: "Example University",
                favoriteDrink: "Coffee",
                location: "Location(latitude: 137, longitude: 20)",
                profilePictures: "",
                matches: "Loves SwiftUI",
                swipes: "",
                voteWeight: 0,
                accountType: "regular",
                sexualPreference: "straight",
                phoneNumber: ""
            )
        )
    }
}
