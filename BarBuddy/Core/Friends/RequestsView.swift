// MARK: - RequestsView.swift (Updated)
import SwiftUI
import FirebaseAuth

struct RequestsView: View {
    @StateObject private var friendService = FriendService.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(friendService.friendRequests) { user in
                    HStack {
                        AsyncImage(url: URL(string: user.profile_pictures?.values.first ?? "")) { phase in
                            switch phase {
                            case .success(let img): img.resizable()
                            default: Image(systemName: "person.crop.circle.fill").resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text("\(user.first_name) \(user.last_name)")
                                .font(.headline)
                            Text(user.hometown)
                                .font(.subheadline)
                        }

                        Spacer()

                        Button("Accept") { Task { await friendService.respond(to: user, accept: true) } }
                            .buttonStyle(.borderedProminent)
                        Button("Decline") { Task { await friendService.respond(to: user, accept: false) } }
                            .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Friend Requests")
            .task { await friendService.loadFriendRequests() }
        }
    }
}



#Preview {
    RequestsView()
}
