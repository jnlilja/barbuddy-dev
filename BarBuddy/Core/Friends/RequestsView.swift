// MARK: - RequestsView.swift (Updated)
import SwiftUI
import FirebaseAuth

struct RequestsView: View {
    @StateObject private var friendService = FriendService.shared
    @State private var searchText: String = ""
    @State private var allUsers: [GetUser] = []

    private var filteredSearchUsers: [GetUser] {
        let q = searchText.lowercased()
        return allUsers.filter { $0.username.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar under title
                    TextField("Search by username", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 16)

                    // Combined list: search results + pending requests
                    List {
                        if !searchText.isEmpty {
                            Section(header: Text("Search Results").foregroundColor(.white)) {
                                ForEach(filteredSearchUsers) { user in
                                    HStack {
                                        Text(user.username)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button("Add") {
                                            Task { await friendService.sendFriendRequest(to: user) }
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                    .listRowBackground(Color("DarkBlue"))
                                }
                            }
                        }

                        Section(header: Text("Added Me").foregroundColor(.white)) {
                            ForEach(friendService.friendRequests) { user in
                                HStack {
                                    AsyncImage(url: URL(string: user.profile_pictures.first ?? "")) { phase in
                                        switch phase {
                                        case .success(let img): img.resizable().scaledToFill()
                                        default: Image(systemName: "person.crop.circle.fill").resizable().scaledToFill()
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())

                                    VStack(alignment: .leading) {
                                        Text("\(user.first_name) \(user.last_name)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(user.hometown ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }

                                    Spacer()

                                    Button("Accept") {
                                        Task { await friendService.respond(to: user, accept: true) }
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Decline") {
                                        Task { await friendService.respond(to: user, accept: false) }
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.vertical, 8)
                                .listRowBackground(Color("DarkBlue"))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .toolbar {
                // Centered title
                ToolbarItem(placement: .principal) {
                    Text("Add Friends")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .task {
                await friendService.loadFriendRequests()
                let result = await GetUserAPIService.shared.fetchUsers()
                switch result {
                case .success(let success):
                    allUsers = success
                case .failure(let failure):
                    print("failed to get users")
                }
            }
        }
    }
}

#Preview {
    RequestsView()
}

