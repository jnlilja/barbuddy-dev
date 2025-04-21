import SwiftUI

struct ComposeMessageView: View {
    @State private var messageText: String = ""
    @State private var recipient: String = ""
    @State private var messages: [MockMessage] = []  // Using Message model now
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            VStack(spacing: 12) {
                Text("New Message")
                    .foregroundColor(.nude)
                    .font(.title2)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 360, height: 50)
                    HStack {
                        Text("To:")
                            .foregroundColor(.darkBlue)
                            .font(.headline)

                        TextField("", text: $recipient)
                            .frame(width: 300)
                    }
                    .padding(.horizontal)
                }

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
                        .padding(.vertical, 8)
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
    ComposeMessageView()
}
