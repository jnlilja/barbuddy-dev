//
//  MessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import FirebaseAuth

struct MessagesView: View {
    @StateObject private var vm = UsersViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentUserID: Int? = nil
    @State private var isLoadingUserID = true

    var body: some View {
        NavigationStack {
            if isLoadingUserID {
                ZStack {
                    Color.darkBlue
                        .ignoresSafeArea()
                    ProgressView("Loading Messages…")
                        .foregroundColor(.white)
                }
            } else {
                ZStack {
                    Color.darkBlue
                        .ignoresSafeArea()

                    if vm.users.isEmpty {
                        NoMessagesView()
                    } else {
                        List(vm.users) { user in
                            NavigationLink {
                                // Force-unwrap is safe here because we finished loading
                                ConversationView(
                                    currentUserID: currentUserID!,
                                    otherUserID: user.id ?? -1,
                                    otherUsername: user.firstName
                                )
                                .navigationBarBackButtonHidden()
                            } label: {
                                DirectMessageRow(
                                    name: user.firstName,
                                    message: "Hey man, how's it going?",
                                    location: String(user.location?.latitude ?? -1) + ", " + String(user.location?.longitude ?? -1)
                                )
                            }
                            .listRowBackground(Color("DarkBlue"))
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.darkBlue, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Text("Messages")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ComposeMessageView()
                                .navigationBarBackButtonHidden()
                        } label: {
                            Image(systemName: "plus.message.fill")
                                .foregroundStyle(.salmon)
                                .font(.title3)
                        }
                    }
                }
                .task {
                    await fetchCurrentUserID()
                }
            }
        }
    }
    
    /// Fetch backend user list, match on Firebase UID, store numeric ID
    private func fetchCurrentUserID() async {
        guard let id = authVM.currentUser?.id else {
            isLoadingUserID = false
            return
        }
        do {
            let users = try await NetworkManager.shared.fetchUsers()
            if let me = users.first(where: { $0.id == id }) {
                currentUserID = me.id
            }
        } catch {
            print("⚠️ fetchCurrentUserID error: \(error)")
        }
        isLoadingUserID = false
    }
}


// Preview with dummy environment
#Preview {
    MessagesView()
        .environmentObject(AuthViewModel())
}
