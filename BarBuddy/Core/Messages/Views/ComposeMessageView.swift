import SwiftUI
import FirebaseAuth

struct ComposeMessageView: View {
    @State private var messageText: String = ""
    @State private var recipientUsername: String = ""
    @FocusState private var isInputFocused: Bool
    @StateObject private var messaging = MessagingService.shared

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

                        TextField("Username", text: $recipientUsername)
                            .frame(width: 300)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal)
                }

                Spacer()

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
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let rid = Int(recipientUsername.trimmingCharacters(in: .whitespacesAndNewlines)),
              !trimmedText.isEmpty else {
            return
        }
        Task {
            await messaging.send(recipientID: rid, content: trimmedText)
        }
        messageText = ""
        isInputFocused = false
    }
}

// Preview
struct ComposeMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeMessageView()
    }
}
