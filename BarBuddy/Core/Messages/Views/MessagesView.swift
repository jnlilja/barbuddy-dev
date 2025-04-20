//
//  MessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI

struct MessagesView: View {
    var hasMessages: Bool = false // Only for testing purposes
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.darkBlue)  // Dark blue background
                    .ignoresSafeArea()

                if !hasMessages {
                    NoMessagesView()
                }
                else {
                    // Decided to change to list since it has better pagentation support
                    List {
                        Section(
                            header: Text("Groups")
                                .font(.title)  // Larger font
                                .foregroundColor(.white)
                                .bold()
                        ) {
                            ForEach(0..<1) { _ in
                                // Group Cards
                                GroupChatCard(
                                    groupName: "Golden Girls 💕",
                                    message:
                                        "This app is insane",
                                    memberImages: ["", "", ""]
                                )
                                
                            }
                            .listRowBackground(Color("DarkBlue"))
                        }
                        
                        Section(
                            header: Text("DM's")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                        ) {
                            ForEach([GetUser.MOCK_DATA], id: \.self) { user in
                                DirectMessageRow(
                                    name: user.first_name + " " + "Betancourt",
                                    message: "Hey man, how's it going?",
                                    location: "Hideaway"
                                )
                            }
                            .listRowBackground(Color("DarkBlue"))
                        }
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.darkBlue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar {
                //Header
                ToolbarItem(placement: .navigation) {
                    Text("Messages")
                        .font(.largeTitle)  // Larger font
                        .bold()
                        .foregroundColor(.white)  // Changed to white for contrast
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CreateNewMessageView()
                    } label: {
                        Image(systemName: "plus.message.fill")
                            .foregroundStyle(.salmon)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    MessagesView()
}
