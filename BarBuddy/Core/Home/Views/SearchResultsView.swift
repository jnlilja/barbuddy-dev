//
//  SearchResultsView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/17/25.
//

import SwiftUI
import BottomSheet

struct SearchResultsView: View {
    @Environment(BarViewModel.self) var viewModel
    @Environment(MapViewModel.self) var mapViewModel
    @Binding var searchText: String
    @Binding var isLoading: Bool
    var position: Binding<BottomSheetPosition>?
    var focus: FocusState<Bool>
    
    private var filteredBars: [Bar] {
        viewModel.bars.filter {
            searchText.isEmpty
            || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        if isLoading {
            ForEach(0..<5) { _ in
                SkeletonRowView()
                    .padding([.horizontal, .bottom])
            }
        } else {
            ScrollView {
                if filteredBars.isEmpty {
                    ContentUnavailableView("No Bars Found", systemImage: "magnifyingglass")
                        .foregroundStyle(.white)
                }
                LazyVStack(spacing: 10) {
                    ForEach(filteredBars) { bar in
                        Button {
                            mapViewModel.updateCameraPosition(query: bar.name, viewModel.bars)
                            position?.wrappedValue = .relativeBottom(0.21)
                            focus.wrappedValue = false
                            
                        } label: {
                            SearchResultsRowView(bar: bar)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            }
            .transaction { $0.animation = nil }
            .scrollDismissesKeyboard(.immediately)
            .padding(.bottom, 90)
            .ignoresSafeArea(.keyboard)
            .scrollDisabled(filteredBars.isEmpty)
        }
    }
}
#if DEBUG
#Preview {
    @Previewable @State var searchText: String = ""
    @Previewable @FocusState var focus: Bool
    NavigationStack {
        SearchResultsView(searchText: $searchText, isLoading: .constant(false), focus: _focus)
            .background(Color.darkBlue)
    }
    .environment(BarViewModel.preview)
    .environment(MapViewModel())
}
#Preview("Loading State") {
    @Previewable @State var searchText: String = ""
    @Previewable @FocusState var focus: Bool
    NavigationStack {
        SearchResultsView(searchText: $searchText, isLoading: .constant(true), focus: _focus)
            .background(Color.darkBlue)
    }
    .environment(BarViewModel.preview)
    .environment(MapViewModel())
}
#Preview("No Results") {
    @Previewable @State var searchText: String = "Altitude"
    @Previewable @FocusState var focus: Bool
    NavigationStack {
        ZStack {
            Color.darkBlue
            
            SearchResultsView(searchText: $searchText, isLoading: .constant(false), focus: _focus)
                .background(Color.darkBlue)
        }
    }
    .environment(BarViewModel.preview)
    .environment(MapViewModel())
}
#endif
