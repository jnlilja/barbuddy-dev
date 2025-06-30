//
//  ApperanceSettingView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/30/25.
//

import SwiftUI

struct AppearanceSettingView: View {
    @AppStorage("selectedAppearance") var selectedAppearance: Appearance = .system

    var apperance: ColorScheme? {
        switch selectedAppearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    var body: some View {
        VStack {
            Text("Set Apperance")
                .font(.title)
                .padding(.top)
            
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("System Apperance")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Circle()
                        .stroke(style: .init(lineWidth: 2))
                        .frame(width: 20, height: 20)
                        .foregroundColor(.nude)
                        .background(.darkBlue)
                        .clipShape(.circle)
                        .padding(.trailing)
                }
                
                Text("Light Mode")
                    .foregroundColor(.primary)
                    .font(.headline)
                
                Text("Dark Mode")
                    .foregroundColor(.primary)
                    .font(.headline)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AppearanceSettingView()
}

