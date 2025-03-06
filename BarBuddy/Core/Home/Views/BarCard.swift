//
//  BarCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct BarCard: View {
    @State private var showingDetail = false
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            HStack {
                Text("Hideaway")
                    .font(.system(size: 32, weight: .bold))
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .neonPink : Color("DarkBlue"))
                
                Spacer()
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color("NeonPink"))
                        .font(.system(size: 24))
                    Text("Trending")
                        .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            
            // Open Hours
            Text("Open 11am - 2am")
                .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
            
            // Bar Image
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
            
            // Quick Info Icons
            HStack(spacing: 12) {
                InfoTag(icon: "music.note", text: "House")
                InfoTag(icon: "person.3.fill", text: "Packed")
                InfoTag(icon: "dollarsign.circle", text: "$5-20")
            }
            .frame(maxWidth: .infinity)
            
            // Action Buttons
            VStack(spacing: 10) {
                ActionButton(
                    text: "See who's there",
                    icon: "person.2.fill",
                    action: { selectedTab = 0 }
                )
                ActionButton(
                    text: "Check the line",
                    icon: "antenna.radiowaves.left.and.right",
                    action: { showingDetail = true }
                )
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            BarDetailPopup()
        }
    }
}

#Preview("Bar Card") {
    BarCard(selectedTab: .constant(0))
}
