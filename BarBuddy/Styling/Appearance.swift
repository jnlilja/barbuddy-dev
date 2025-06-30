//
//  Appearance.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/30/25.
//
import Foundation
enum Appearance: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    var id: String { self.rawValue }
}
