//
//  ImageTileView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/15/25.
//
import SwiftUI

struct ImageTileView: View {
    @State var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
    }
}
