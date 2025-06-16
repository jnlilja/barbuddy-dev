//
//  ButtonBehavior.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/9/25.
//

import Foundation

struct VoteButtonState {
    var didSubmit: Bool = false
    var showMenu: Bool = false
    var offset: CGFloat = 0
    let type: String
    var beginTimer: Bool = false
}
