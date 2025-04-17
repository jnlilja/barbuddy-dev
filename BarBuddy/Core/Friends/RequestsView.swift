import SwiftUI

struct RequestsView: View {
    @StateObject private var vm            = UsersViewModel()
    @State private var selectedUser: GetUser?

    var body: some View {
        NavigationStack {
            List(vm.users) { user in
                HStack {
                    Image(user.profile_pictures?.values.first ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text("\(user.first_name) \(user.last_name)")
                            .font(.headline)
                        Text(user.hometown)
                            .font(.subheadline)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedUser = user
                    }

                    Spacer()

                    Button("Accept") {
                        Task {
                            let post = PostUser(
                                username: user.username,
                                first_name: user.first_name,
                                last_name: user.last_name,
                                email: user.email,
                                password: user.password,
                                date_of_birth: user.date_of_birth,
                                hometown: user.hometown,
                                job_or_university: user.job_or_university,
                                favorite_drink: user.favorite_drink,
                                profile_pictures: user.profile_pictures,
                                account_type: user.account_type,
                                sexual_preference: user.sexual_preference
                            )
                            try? await PostUserAPIService.shared.create(user: post)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("DarkPurple"))
                    .cornerRadius(8)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Friend Requests")
            .onAppear { vm.loadUsers() }
            .navigationDestination(item: $selectedUser) { user in
                FriendProfile(user: user)
            }
        }
    }
}


#Preview {
    RequestsView()
}
