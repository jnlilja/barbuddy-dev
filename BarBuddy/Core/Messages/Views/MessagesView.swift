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
    
    /// The signed‑in user’s numeric ID.
    /// TODO: Replace this default with the actual authenticated user ID.
    let currentUserID: Int

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBlue
                    .ignoresSafeArea()

                if vm.users.isEmpty {
                    NoMessagesView()
                } else {
                    List(vm.users) { user in
                        NavigationLink {
                            ConversationView(
                                currentUserID: currentUserID,
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
                            .navigationBarBackButtonHidden()
                    } label: {
                        Image(systemName: "plus.message.fill")
                            .foregroundStyle(.salmon)
                            .font(.title3)
                    }
                }
            }
        }
        .onAppear {
            vm.loadUsers()
        }
    }
}

// Preview with a sample user ID
struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(currentUserID: 123)
    }
}
