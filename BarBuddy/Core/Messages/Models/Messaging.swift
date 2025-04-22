//
//  Messaging.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/21/25.
//

// MessagingService.swift

import Foundation
import FirebaseAuth
import PusherSwift

// MARK: - ChatMessage model
/// Renamed from `Message` to avoid conflicts with other types
public struct ChatMessage: Codable, Identifiable {
    public let id: Int
    public let sender: Int
    public let recipient: Int
    public let content: String
    public let timestamp: String
    public let is_read: Bool
    public let sender_username: String
    public let recipient_username: String
}

// MARK: - Request payload for sending
private struct MessageRequest: Codable {
    let recipient: Int
    let content: String
}

// MARK: - MessagingService
@MainActor
public final class MessagingService: ObservableObject {
    public static let shared = MessagingService()

    private let baseURL = URL(string: "https://YOUR_API_BASE_URL/")!
    private var pusher: Pusher?
    private var channel: PusherChannel?

    /// Published list of all messages (filtered in views)
    @Published public var messages: [ChatMessage] = []

    // Build an authenticated URLRequest
    private func makeAuthRequest(path: String) async throws -> URLRequest {
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }

    // MARK: - Fetch all messages
    public func fetchAllMessages() async {
        do {
            var req = try await makeAuthRequest(path: "messages")
            req.httpMethod = "GET"
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode([ChatMessage].self, from: data)
            messages = decoded
        } catch {
            print("⚠️ MessagingService.fetchAllMessages failed: \(error)")
        }
    }

    // MARK: - Send a new message
    public func send(recipientID: Int, content: String) async {
        do {
            var req = try await makeAuthRequest(path: "messages")
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(MessageRequest(recipient: recipientID, content: content))

            let (data, _) = try await URLSession.shared.data(for: req)
            let sent = try JSONDecoder().decode(ChatMessage.self, from: data)
            messages.append(sent)
            await triggerPusherEvent(for: sent)
        } catch {
            print("⚠️ MessagingService.send failed: \(error)")
        }
    }

    // MARK: - Pusher trigger event (POST)
    private func triggerPusherEvent(for message: ChatMessage) async {
        do {
            var req = try await makeAuthRequest(path: "pusher/trigger")
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let payload: [String: Any] = [
                "channel": "private-messages-\(message.recipient)",
                "event": "new-message",
                "data": [
                    "id": message.id,
                    "sender": message.sender,
                    "recipient": message.recipient,
                    "content": message.content,
                    "timestamp": message.timestamp,
                    "is_read": message.is_read,
                    "sender_username": message.sender_username,
                    "recipient_username": message.recipient_username
                ]
            ]

            req.httpBody = try JSONSerialization.data(withJSONObject: payload)
            _ = try await URLSession.shared.data(for: req)
        } catch {
            print("⚠️ MessagingService.triggerPusherEvent failed: \(error)")
        }
    }

    // MARK: - Subscribe to real‑time updates
    public func startRealtime(for channelName: String) {
        let options = PusherClientOptions(host: .cluster("YOUR_PUSHER_CLUSTER"))
        pusher = Pusher(key: "YOUR_PUSHER_KEY", options: options)
        channel = pusher?.subscribe(channelName)

        channel?.bind(eventName: "new-message") { [weak self] event in
            guard
                let payload = event.data,
                let json = payload.data(using: .utf8),
                let msg = try? JSONDecoder().decode(ChatMessage.self, from: json)
            else {
                print("↘️ Failed to parse PusherEvent:", event.data ?? "no data")
                return
            }
            DispatchQueue.main.async {
                self?.messages.append(msg)
            }
        }
        pusher?.connect()
    }

    // MARK: - Unsubscribe
    public func stopRealtime() {
        guard let chan = channel?.name else { return }
        pusher?.unsubscribe(chan)
        pusher?.disconnect()

        Task {
            do {
                var req = try await makeAuthRequest(path: "pusher/unsubscribe")
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = ["channel": chan]
                req.httpBody = try JSONSerialization.data(withJSONObject: body)
                _ = try await URLSession.shared.data(for: req)
            } catch {
                print("⚠️ MessagingService.stopRealtime unsubscribe POST failed: \(error)")
            }
        }
    }
}
