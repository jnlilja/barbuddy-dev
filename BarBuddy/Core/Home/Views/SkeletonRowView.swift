//
//  SkeletonRowView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/20/25.
//

import SwiftUI
import Shimmer

struct SkeletonRowView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 180, height: 20)
                    .foregroundColor(Color(.tertiarySystemGroupedBackground))
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 20)
                    .foregroundColor(Color(.tertiarySystemGroupedBackground))
            }

            Spacer()

            RoundedRectangle(cornerRadius: 10)
                .frame(width: 70, height: 20)
                .foregroundColor(Color(.quaternaryLabel))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedCorner(radius: 10))
        .shimmering()
    }
}

#Preview {
    SkeletonRowView()
}
