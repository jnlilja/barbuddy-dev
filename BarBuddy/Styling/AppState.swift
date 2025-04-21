//
//  AppState.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/20/25.
//

import Foundation
import UIKit

/*  Helper class and extension to enable swipe to previous view since I hide the
    back button for this view which disables the geasture by default
 */
@MainActor
class AppState {
    static let shared = AppState()
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
