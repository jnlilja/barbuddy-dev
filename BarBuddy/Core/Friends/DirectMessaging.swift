//
//  DirectMessaging.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 2/26/25.
//

import SwiftUI

// MARK: - Message Model
struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
    let timestamp: Date
}

// MARK: - Direct Messaging View
struct DirectMessagingView: View {
    let friend: Friend
    
    // Remove any hard-coded messages:
    @State private var messages: [Message] = []
    @State private var newMessageText: String = ""
    @State private var showProfile = false
    
    // Use presentationMode to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            
            // Top "profile" section with custom back button
            topProfileSection
            
            // Divider or small spacer
            Divider()
            
            // Messages list or placeholder
            if messages.isEmpty {
                // No prior messages
                VStack {
                    Spacer()
                    Text("No messages yet.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text("Say hi to \(friend.name)!")
                        .font(.subheadline)
                        .foregroundColor(.darkPurple)
                    Spacer()
                }
            } else {
                // Display messages
                ScrollView {
                    ScrollViewReader { scrollProxy in
                        VStack(spacing: 12) {
                            ForEach(messages) { message in
                                chatBubble(for: message)
                                    .padding(.horizontal)
                            }
                        }
                        .onChange(of: messages) { _ in
                            // Scroll to the bottom when a new message is added
                            if let lastMessage = messages.last {
                                withAnimation {
                                    scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            
            // Text field to enter new messages
            messageInputBar
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: FriendProfileView(friend: friend),
                isActive: $showProfile,
                label: { EmptyView() }
            )
        )
    }
}

// MARK: - Subviews
extension DirectMessagingView {
    
    /// Top profile section with a custom back button to return to the friends list
    private var topProfileSection: some View {
        VStack(spacing: 6) {
            // Back button at the top
            HStack {
                Button(action: {
                    // Dismiss the current view, returning to the previous screen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.darkPurple)
                        .padding()
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Profile image with tap gesture
            Button(action: {
                showProfile = true
            }) {
                Image(friend.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            
            // Friend's name (dynamically set)
            Text(friend.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Friend handle based on name formatting
            Text("@\(friend.name.lowercased().replacingOccurrences(of: " ", with: "_"))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("You both are friends with ect")
                .font(.footnote)
                .foregroundColor(.gray)
            
            // "View profile" button (action can be added later)
            Button(action: {
                showProfile = true
            }) {
                Text("View profile")
                    .font(.footnote)
                    .foregroundColor(.darkPurple)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.darkPurple, lineWidth: 1)
                    )
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, 8)
    }
    
    /// Individual chat bubble
    private func chatBubble(for message: Message) -> some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .id(message.id)
            } else {
                Text(message.text)
                    .padding(10)
                    .foregroundColor(.black)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    .id(message.id)
                Spacer()
            }
        }
    }
    
    /// Bottom input bar for new messages
    private var messageInputBar: some View {
        HStack {
            TextField("Message...", text: $newMessageText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            Button(action: sendMessage) {
                Text("Send")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.darkPurple)
                    .cornerRadius(16)
            }
        }
        .padding()
        .background(Color.white.shadow(radius: 2))
    }
    
    // MARK: - Actions
    private func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newMessage = Message(
            text: trimmed,
            isCurrentUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        newMessageText = ""
    }
}

// MARK: - Preview
struct DirectMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        // A sample friend to pass into DirectMessagingView
        let sampleFriend = Friend(
            name: "Michael Brown",
            occupation: "Software Engineer",
            profileImage: "guy1",
            isOut: true
        )
        NavigationView {
            DirectMessagingView(friend: sampleFriend)
        }
    }
}
