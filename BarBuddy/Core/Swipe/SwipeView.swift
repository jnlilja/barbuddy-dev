import SwiftUI

struct SwipeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var vm = SwipeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue").ignoresSafeArea()
                    // ——— Card stack ———
                    ZStack {
                        if vm.users.isEmpty {
                            Text("No more users")
                                .font(.title)
                                .foregroundColor(.white)
                        } else {
                            ForEach(vm.users.reversed()) { profile in
                                SwipeCard(profile: profile)
                                    .clipShape(RoundedRectangle(cornerRadius: 60))
                                    .overlay(actionButtons(for: profile))
                                    .padding(.top, -20)
                            }
                    }

                    Spacer()
                }

                // Error banner
                if let msg = vm.errorMessage {
                    VStack {
                        Spacer()
                        Text(msg)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                if let user = sessionManager.currentUser {
                    await vm.loadSuggestions(username: user.username)
                }
            }
        }
    }

    // MARK: - Like / dislike buttons overlay
    private func actionButtons(for profile: UserProfile) -> some View {
        HStack {
            // Dislike
            Button {
                withAnimation { vm.swipeLeft(profile: profile) }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 26))
                            .foregroundColor(.red)
                    )
            }
            .padding(.leading, 30)

            Spacer()

            // Like
            Button {
                withAnimation { vm.swipeRight(profile: profile) }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color("Salmon"))
                    )
            }
            .padding(.trailing, 30)
        }
        .offset(y: UIScreen.main.bounds.height * 0.085)
    }
}

#Preview {
    SwipeView()
        .environmentObject(SessionManager())
}
