//
//  ApperanceSettingView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/30/25.
//

import SwiftUI

struct AppearanceSettingView: View {
    var body: some View {
        List(Appearance.allCases, selection: $selectedAppearance) {
            Text($0.rawValue).tag($0)
        }
    }
}

#Preview {
    AppearanceSettingView()
}

