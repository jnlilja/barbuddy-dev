//
//  SignUpTextFieldView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/27/25.
//
import SwiftUI

struct SignUpTextFieldView: View {
    let prompt: String
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    let geometry: GeometryProxy
    var isPassword: Bool?
    
    var body: some View {
        VStack(alignment: .leading) {
            // ───────── Email
            if let password = isPassword, password {
                SecureField("", text: $text, prompt: Text(prompt).foregroundStyle(colorScheme == .dark ? .nude : .darkBlue))
                    .padding()
                    .frame(width: geometry.size.width / 1.1, height: 50)
                    .background(colorScheme == .dark ? .darkBlue : .white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(.darkPurple, lineWidth: 1))
                    
            } else {
                TextField("", text: $text, prompt: Text(prompt).foregroundStyle(colorScheme == .dark ? .nude : .darkBlue))
                .padding()
                .frame(width: geometry.size.width / 1.1, height: 50)
                .background(colorScheme == .dark ? .darkBlue : .white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(.darkPurple, lineWidth: 1))
            }
        }
    }
}
