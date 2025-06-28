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
    let geometry: GeometryProxy
    
    var body: some View {
        let width = geometry.size.width / 4
        let height: CGFloat = 35
        
        HStack(spacing: 15) {
            ZStack {
                if selection == 0 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Photos", isSelected: selection == 0, geometry: geometry) { selection = 0 }
            }
            
            ZStack {
                if selection == 1 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                }
                
                TabButton(text: "Info",    isSelected: selection == 1, geometry: geometry) { selection = 1 }
            }
            ZStack {
                if selection == 2 {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: width, height: height)
                        .foregroundStyle(color.gradient)
                        .matchedGeometryEffect(id: "button", in: animation)
                    
                }
                TabButton(text: "Friends", isSelected: selection == 2, geometry: geometry) { selection = 2 }
            }
        }
        .padding(.horizontal, 10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(25)
        .animation(.smooth, value: selection)
    }
}

#Preview {
    @Previewable @State var selection: Int = 0
    GeometryReader { geometry in
        HStack {
            Spacer()
            VStack {
                Spacer()
                ProfileTabView(selection: $selection, geometry: geometry)
                Spacer()
            }
            Spacer()
        }
    }
    .background(.darkBlue)
}
