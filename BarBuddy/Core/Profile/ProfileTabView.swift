//
//  ProfileTabView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/23/25.
//

import SwiftUI

struct ProfileTabView: View {
    @Binding var selection: Int
    var color: Color = .salmon
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                if selection == 0 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 75, height: 35)
                        .foregroundStyle(color.gradient)
                        .shadow(radius: 10)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Photos", isSelected: selection == 0) { selection = 0 }
            }
            
            ZStack {
                if selection == 1 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 75, height: 35)
                        .foregroundStyle(color.gradient)
                        .shadow(radius: 10)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Info",    isSelected: selection == 1) { selection = 1 }
            }
            ZStack {
                if selection == 2 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 75, height: 35)
                        .foregroundStyle(color.gradient)
                        .shadow(radius: 10)
                        .matchedGeometryEffect(id: "button", in: animation)
                    
                }
                TabButton(text: "Friends", isSelected: selection == 2) { selection = 2 }
            }
        }
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(25)
        .animation(.snappy, value: selection)
    }
}
