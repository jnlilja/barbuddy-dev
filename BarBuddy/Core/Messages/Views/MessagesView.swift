//
//  MessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI

struct MessagesView: View {
    var hasMessages: Bool = true  // Only for testing purposes
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.darkBlue)  // Dark blue background
                    .ignoresSafeArea()

                if !hasMessages {
                    NoMessagesView()
                } else {
                    // Decided to change to list since it has better pagentation support
                    List {
                        ForEach([GetUser.MOCK_DATA], id: \.self) { user in
                            
                            DirectMessageRow(
                                name: user.first_name,
                                message: "Hey man, how's it going?",
                                location: "Hideaway"
                                
                            )
                            .overlay {
                                NavigationLink("") {
                                    ConversationView(recipient: user.first_name)
                                        .navigationBarBackButtonHidden()
                                }
                                .opacity(0)
                            }
                        }
                        .listRowBackground(Color("DarkBlue"))
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.darkBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
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
    }
}

#Preview {
    MessagesView()
}
