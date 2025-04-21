//
//  ConversationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/20/25.
//

import SwiftUI
import FirebaseAuth

struct ConversationView: View {
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    @StateObject private var messaging = MessagingService.shared

    /// IDs for the current user and the conversation partner
    let currentUserID: Int
    let otherUserID: Int
    let otherUsername: String

    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            VStack(spacing: 12) {
                MessageHeaderView(location: nil, recipient: otherUsername)
                    .padding(.top)

                ZStack {
                    Color.salmon.opacity(0.15)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            // Filter the shared messages for this two‑person thread
                            let convo = messaging.messages.filter {
                                ($0.sender == currentUserID && $0.recipient == otherUserID) ||
                                ($0.sender == otherUserID && $0.recipient == currentUserID)
                            }
                            ForEach(convo) { message in
                                HStack {
                                    if message.sender == otherUserID {
                                        // Incoming bubble
                                        Text(message.content)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                            .frame(maxWidth: 250, alignment: .leading)
                                        Spacer()
                                    } else {
                                        // Outgoing bubble
                                        Spacer()
                                        Text(message.content)
                                            .padding()
                                            .background(Color.salmon)
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                            .frame(maxWidth: 250, alignment: .trailing)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .defaultScrollAnchor(.bottom)
                    .padding(.bottom)
                }

                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFocused)
                        .onSubmit { sendMessage() }

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .rotationEffect(.degrees(45))
                            .foregroundColor(
                                messageText.isEmpty ? .gray : .salmon
                            )
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            Task {
                // Load history and subscribe to real‑time
                await messaging.fetchAllMessages()
                let channel = "private-messages-\(otherUserID)"
                messaging.startRealtime(for: channel)
            }
        }
        .onDisappear {
            messaging.stopRealtime()
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Task {
            await messaging.send(recipientID: otherUserID, content: text)
        }
        messageText = ""
        isInputFocused = false
    }
}

// Preview
struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(
            currentUserID: 123,
            otherUserID: 456,
            otherUsername: "Alice"
        )
    }
}
