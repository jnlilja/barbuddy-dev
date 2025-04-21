//
//  CreateNewMessageView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/19/25.
//

import SwiftUI

struct ComposeMessageView: View {
    @State private var messageText: String = ""
    @State private var recipient: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            VStack {
                Text("New Message")
                    .foregroundColor(.nude)
                    .font(.headline)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 300, height: 50)
                    HStack {
                        Text("To:")
                            .foregroundColor(.darkBlue)
                            .font(.headline)
                        
                        TextField("", text: $recipient)
                            .frame(width: 240)
                            //.padding(.trailing, 40)
                    }
                }
                Spacer()
                ScrollView {
                    Text("Hello World")
                        .foregroundStyle(.white)
                        .font(.caption)
                }
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(10)
                        .focused($isInputFocused)
                    
                    Button {
                        
                    }label: {
                        Image(systemName: "paperplane.fill")
                            .rotationEffect(.degrees(45))
                            .foregroundColor(messageText.isEmpty ? .gray : .salmon)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
        }
    }
}


#Preview {
    ComposeMessageView()
}
