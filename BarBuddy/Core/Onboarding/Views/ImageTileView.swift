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
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: 600)
    }
}

#Preview {
    @Previewable @State var image: UIImage = UIImage(named: "logo")!
    ZStack {
        Color.darkBlue.ignoresSafeArea()
        ImageTileView(image: image)
    }
}
