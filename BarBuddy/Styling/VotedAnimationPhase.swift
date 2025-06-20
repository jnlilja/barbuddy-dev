//
//  VotedAnimationPhase.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/19/25.
//
import Foundation

enum VotedAnimationPhase: CaseIterable {
    case down, up
    
    var scale: CGFloat {
        switch self {
        case .down:
            return 1
        case .up:
            return 1.1
        }
    }
}
