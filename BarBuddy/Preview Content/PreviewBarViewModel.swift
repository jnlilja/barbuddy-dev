//
//  SampleBarViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/19/25.
//

import Foundation

extension BarViewModel {
    @MainActor static let preview: BarViewModel = {
        let viewModel = BarViewModel()
        viewModel.bars = Bar.sampleBars
        viewModel.statuses = BarStatus.sampleStatuses
        viewModel.hours = BarHours.sampleHours
        
        return viewModel
    }()
}
