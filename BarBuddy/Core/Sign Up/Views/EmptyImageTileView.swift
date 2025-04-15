//
//  EmptyImageTileView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/15/25.
//
import SwiftUI
struct EmptyImageTileView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.black.opacity(0.1))
            .frame(width: 100, height: 100)

        Image(systemName: "plus")
            .font(.system(size: 30))
            .foregroundColor(.white)
    }
}
#Preview {
    EmptyImageTileView()
}
