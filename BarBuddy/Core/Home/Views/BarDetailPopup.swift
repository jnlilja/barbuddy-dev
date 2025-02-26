//
//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

// Update BarDetailPopup to replace the posting section with the graph
struct BarDetailPopup: View {
    //@Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with bar name and hours
                    VStack(spacing: 8) {
                        Text("Hideaway")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        
                        HStack {
                            Text("Open")
                                .foregroundColor(.red)
                            Text("11am - 2am")
                                .foregroundColor(Color("DarkPurple"))
                        }
                    }
                    
                    // Friends avatars section
                    VStack(spacing: 10) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { _ in
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("+6 of your friends are here!")
                            .foregroundColor(Color("DarkPurple"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    // Quick info tags
                    HStack(spacing: 15) {
                        InfoBubble(icon: "music.note", text: "House")
                        InfoBubble(icon: "flame.fill", text: "Packed")
                        InfoBubble(text: "$ 5 - 20")
                    }
                    
                    // Wait time and crowd size
                    HStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text("Est. Wait Time:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            
                            Text("20 - 30 min")
                                .padding()
                                .background(Color("Salmon").opacity(0.2))
                                .cornerRadius(15)
                            
                            Text("Vote wait time!")
                                .bold()
                                .underline()
                                .foregroundColor(Color("DarkPurple"))
                        }
                        
                        VStack(spacing: 10) {
                            Text("Crowd Size is:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color("DarkPurple"))
                                Text("Packed")
                            }
                            .padding()
                            .background(Color("Salmon").opacity(0.2))
                            .foregroundColor(Color("DarkPurple"))
                            .cornerRadius(15)
                            
                            Text("Vote crowd size!")
                                .bold()
                                .underline()
                                .foregroundColor(Color("DarkPurple"))
                        }
                    }
                    
                    // Replace image and post button with crowd level graph
                    CrowdLevelGraph()
                    
                    // Single action button for Swipe
                    Button(action: {}) {
                        HStack {
                            Text("Swipe")
                            Image(systemName: "person.2.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                //isPresented = false
                dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Update the preview
#Preview("Bar Detail Popup") {
    HomeView()
        .overlay {
            BarDetailPopup()
        }
}
