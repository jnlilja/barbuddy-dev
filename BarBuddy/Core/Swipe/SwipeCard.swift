//
//  SwipeCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SwipeCard: View {
    var body: some View {
        VStack {
            // Profile Image - made taller
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: UIScreen.main.bounds.height * 0.7)  // Increased from 0.6 to 0.7
                .cornerRadius(20)
                .overlay(
                    VStack {
                        Spacer()
                        
                        // User Info Overlay
                        VStack(alignment: .leading, spacing: 12) {
                            // Name and Status
                            HStack {
                                Text("Ashley")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color("DarkPurple"))
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color("NeonPink"))
                                    .font(.system(size: 20))
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Active")
                                }
                                .foregroundColor(Color("DarkPurple"))
                            }
                            
                            // Location and Group
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Hideaway")
                                }
                                .foregroundColor(Color("DarkPurple"))
                                
                                Spacer()
                                
                                Text("Group: Golden Girls")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("Salmon").opacity(0.2))
                                    .cornerRadius(15)
                            }
                            
                            // Stats
                            HStack(spacing: 25) {
                                Label("23", systemImage: "birthday.cake")
                                Label("5'11", systemImage: "ruler")
                                Label("San Diego", systemImage: "house")
                            }
                            .font(.system(size: 16))
                            .foregroundColor(Color("DarkPurple"))
                            
                            // School and Drink
                            HStack(spacing: 25) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color("DarkPurple"))
                                        .frame(width: 25, height: 25)
                                    Text("SDSU")
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "wineglass")
                                    Text("Tequila")
                                }
                            }
                            .font(.system(size: 16))
                            .foregroundColor(Color("DarkPurple"))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                    .padding()
                )
        }
        .padding()
    }
}

struct SwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCard()
            .previewLayout(.device)
            .previewDisplayName("SwipeCard")
    }
}
