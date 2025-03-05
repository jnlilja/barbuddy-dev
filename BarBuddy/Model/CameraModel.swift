//
//  CameraModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/4/25.
//

import SwiftUI
import MapKit

// Kinda silly to make this a class but had to be done
class CameraModel: ObservableObject {
    var cam: MapCameraPosition = .userLocation(fallback: .automatic)
}
