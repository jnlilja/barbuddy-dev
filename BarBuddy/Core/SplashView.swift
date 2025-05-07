//
//  SplashView.swift
//  BarBuddy
//
//  Created by Gwinyai Nyatsoka on 5/5/2025.
//

import SwiftUI
import FirebaseAuth

struct SplashView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            //762CA8
            Color(hex: "#762CA8")
                .ignoresSafeArea()
            VStack {
                Image("BarBuddy Launch Screen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250)
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Loading...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
}

#Preview {
    SplashView()
        .environmentObject(SessionManager())
}
