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
    @State private var currentUserID: Int? = nil
    @State private var isLoadingUserID = false
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            Group {
                if isLoadingUserID {
                    ZStack {
                        Color.darkBlue
                            .ignoresSafeArea()
                        ProgressView("Loading Messages...")
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
                                        otherUserID: user.id,
                                        otherUsername: user.first_name
                                    )
                                    .navigationBarBackButtonHidden()
                                } label: {
                                    DirectMessageRow(
                                        name: user.first_name,
                                        message: "Hey man, how's it going?",
                                        location: user.location
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
                            } label: {
                                Image(systemName: "plus.message.fill")
                                    .foregroundStyle(.salmon)
                                    .font(.title3)
                            }
                        }
                    }
                }
            }
            .task {
                await vm.loadUsers()
            }
            .onAppear {
                fetchCurrentUserID()
            }
        }
        .tint(.salmon)
    }

    /// Fetch backend user list, match on Firebase UID, store numeric ID
    private func fetchCurrentUserID() {
        guard let currentUser = authVM.currentUser else { return }
        currentUserID = currentUser.id
        isLoadingUserID = false
    }
}

// Preview with dummy environment
#Preview {
    MessagesView()
        .environmentObject(AuthViewModel())
}
