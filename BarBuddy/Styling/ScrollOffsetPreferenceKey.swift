//
//  ScrollOffsetPreferenceKey.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/19/25.
//
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // Using nextValue directly to get the current offset from the GeometryReader
        value = nextValue()
    }
}
