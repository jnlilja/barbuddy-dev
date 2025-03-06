import MapKit
import SwiftUI

struct MainFeedView: View {
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            BarMapView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }
}
#Preview("Main Feed") {
    MainFeedView()
}
