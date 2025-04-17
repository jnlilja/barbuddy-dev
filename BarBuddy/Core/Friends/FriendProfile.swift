//
//  FriendProfile.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//

import SwiftUI

struct FriendProfile: View {
    let user: GetUser

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photo Gallery
                TabView {
                    ForEach(user.profile_pictures?.values.sorted() ?? [], id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 457)
                            .clipped()
                    }
                }
                .frame(height: 457)
                .tabViewStyle(PageTabViewStyle())

                // Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(user.first_name) \(user.last_name)")
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
                            Text(user.date_of_birth)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                            Text(user.location)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("DarkPurple"))

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                            Text(user.job_or_university)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "wineglass.fill")
                            Text(user.favorite_drink)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                            Text(user.sexual_preference)
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FriendProfile_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendProfile(
                user: GetUser(
                    id: 1,
                    username: "sampleuser",
                    first_name: "Sample",
                    last_name: "User",
                    email: "sample@example.com",
                    password: "password",
                    date_of_birth: "1990-01-01",
                    hometown: "Springfield",
                    job_or_university: "Example University",
                    favorite_drink: "Coffee",
                    location: "Springfield",
                    profile_pictures: ["profilePic": "TestImage"],
                    matches: "Loves SwiftUI",
                    swipes: "",
                    vote_weight: 0,
                    account_type: "regular",
                    sexual_preference: "straight"
                )
            )
        }
    }
}
