//
//  Trending.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/21/25.
//
import SwiftUI
/// Fetches active user counts for a bar and shows a "Trending" badge when count ≥ threshold.
struct Trending: View {
    /// Name of the bar to match user.location against
    let barName: String
    /// Fetched count of users at this bar
    @State private var activeUserCount: Int = 0
    /// Loading state
    @State private var isLoading: Bool = true
    /// Minimum users required to show "Trending"
    private let threshold: Int = 10
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.darkPurple)
            } else if activeUserCount >= threshold {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("NeonPink"))
                    Text("Trending")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
                }
            }
        }
        .onAppear {
            Task { await fetchActiveUsers() }
        }
    }
    /// Fetches all users and counts those whose `location` matches `barName`.
    private func fetchActiveUsers() async {
//        do {
//            let users = try await UsersFeedService.shared.fetchAll()
//            activeUserCount = users.filter { $0.location == barName }.count
//        } catch {
//            print("Error fetching users for trending badge: \(error)")
//            activeUserCount = 0
//        }
//        isLoading = false
    }
}
struct Trending_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Trending(barName: "Hideaway")
                .previewDisplayName("Trending (>=10)")
            Trending(barName: "Thrusters Lounge")
                .previewDisplayName("Not Trending (<10)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
