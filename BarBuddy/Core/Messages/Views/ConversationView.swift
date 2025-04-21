//
//  ConversationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/20/25.
//

import SwiftUI

struct ConversationView: View {
    @State private var messageText: String = ""
    @State var recipient: String
    @State private var messages: [MockMessage] = []
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            VStack(spacing: 12) {

                MessageHeaderView(location: "Dirty Birds", recipient: recipient)
                    .padding(.top)

                ZStack {
                    Color.salmon.opacity(0.15)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isIncoming {
                                        // Incoming bubble
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                            .frame(
                                                maxWidth: 250,
                                                alignment: .leading
                                            )
                                        Spacer()
                                    } else {
                                        // Outgoing bubble
                                        Spacer()
                                        Text(message.text)
                                            .padding()
                                            .background(Color.salmon)
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                            .frame(
                                                maxWidth: 250,
                                                alignment: .trailing
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom)
                    .defaultScrollAnchor(.bottom)
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
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmed.isEmpty else { return }

        // Outgoing message
        messages.append(MockMessage(text: trimmed, isIncoming: false))

        // Simulate an incoming reply after a short delay
        // Only for testing purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(
                MockMessage(text: "Reply to: \(trimmed)", isIncoming: true)
            )
        }

        messageText = ""
        isInputFocused = false
    }
}

#Preview {
    ConversationView(recipient: "Alice")
}
