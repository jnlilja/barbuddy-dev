//
//  CustomTextFieldStyle.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("DarkPurple"), lineWidth: 1)
            )
    }
}
