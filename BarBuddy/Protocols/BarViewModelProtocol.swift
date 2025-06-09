//
//  BarViewModelProtocol.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 1/8/25.
//

import Foundation

@MainActor
protocol BarViewModelProtocol: Observable {
    var bars: [Bar] { get set }
    var statuses: [BarStatus] { get set }
    var hours: [BarHours] { get set }
    
    func formatBarHours(hours: inout BarHours) -> String?
}
