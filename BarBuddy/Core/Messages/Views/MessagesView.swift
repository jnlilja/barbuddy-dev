import FirebaseAuth
//
//  MessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI

struct MessagesView: View {
    @State private var isLoadingUserID = false
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBlue
                    .ignoresSafeArea()
                
                if isLoadingUserID {
                    ProgressView("Loading Messages...")
                        .foregroundColor(.white)
                } else {
                    NoMessagesView()
                }
                
            }
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
                    } label: {
                        Image(systemName: "plus.message.fill")
                            .foregroundStyle(.salmon)
                            .font(.title3)
                    }
                }
            }
        }
        .tint(.salmon)
    }
}

// Preview with dummy environment
#Preview {
    MessagesView()
        .environmentObject(AuthViewModel())
}
