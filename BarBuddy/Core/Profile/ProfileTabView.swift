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
        let width: CGFloat = 110
        let height: CGFloat = 35
        let divider: CGFloat = 4
        
        HStack(spacing: 15) {
            ZStack {
                if selection == 0 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Photos", isSelected: selection == 0) { selection = 0 }
                    .containerRelativeFrame([.horizontal]) { length, axis in
                        length / divider
                    }
            }
            
            ZStack {
                if selection == 1 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Info",    isSelected: selection == 1) { selection = 1 }
                    .containerRelativeFrame([.horizontal]) { length, axis in
                        length / divider
                    }
            }
            ZStack {
                if selection == 2 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                    
                }
                TabButton(text: "Friends", isSelected: selection == 2) { selection = 2 }
                    .containerRelativeFrame([.horizontal]) { length, axis in
                        length / divider
                    }
            }
        }
        .padding(.horizontal, 10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(25)
        .animation(.spring(response: 0.3, dampingFraction: selection == 1 ? 1 : 0.6), value: selection)
    }
}

#Preview {
    @Previewable @State var selection: Int = 0
    ZStack {
        Color.darkBlue.ignoresSafeArea()
        ProfileTabView(selection: $selection)
            
    }
}
