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
            Text(prompt)
                .font(.headline)
                .foregroundStyle(.white)
            if let password = isPassword, password {
                SecureField("", text: $text)
                    .padding()
                    .frame(width: geometry.size.width / 1.1, height: 50)
                    .background(colorScheme == .dark ? .darkBlue : Color.white)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    
            } else {
                TextField(
                    "",
                    text: $text
                )
                .padding()
                .frame(width: geometry.size.width / 1.1, height: 50)
                .background(colorScheme == .dark ? .darkBlue : Color.white)
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
            }
        }
    }
}
