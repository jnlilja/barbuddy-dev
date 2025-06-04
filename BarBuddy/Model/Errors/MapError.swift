//
//  MapError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/26/25.
//

import Foundation

enum MapError: Error {
    case noLocationServices
    case unableToInitializeMapView
    case barNotFound
}
