//
//  BarBoundaries.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//

import Foundation
import MapKit

/// A simple struct for a bar’s location circle.
public struct BarBoundary {
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let radius: CLLocationDistance  // in meters

    /// Returns true if `coord` falls within this bar’s boundary.
    public func contains(_ coord: CLLocationCoordinate2D) -> Bool {
        let loc   = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let other = CLLocation(latitude: coord.latitude,     longitude: coord.longitude)
        return loc.distance(from: other) <= radius
    }
}

/// All your bars with non‑overlapping half‑distance radii (×0.9 for a little gap).
public enum BarBoundaries {
    @MainActor public static let all: [BarBoundary] = [
        BarBoundary(name: "Hideaway",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79642088184946,
                                                       longitude: -117.2555410510165),
                    radius: 39.09),
        BarBoundary(name: "Shoreclub",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79422145724771,
                                                       longitude: -117.25582039522689),
                    radius: 15.24),
        BarBoundary(name: "Firehouse",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79479241368196,
                                                       longitude: -117.25557709615143),
                    radius: 21.97),
        BarBoundary(name: "Local",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79365731842088,
                                                       longitude: -117.25415242129091),
                    radius: 29.59),
        BarBoundary(name: "Open Bar",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79374988692048,
                                                       longitude: -117.25484732393666),
                    radius: 29.59),
        BarBoundary(name: "Beverly Beach Garden",
                    coordinate: CLLocationCoordinate2D(latitude: 32.792524451264605,
                                                       longitude: -117.25448295422973),
                    radius: 49.19),
        BarBoundary(name: "Flamingo Deck",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79120573826967,
                                                       longitude: -117.25409130132003),
                    radius: 52.77),
        BarBoundary(name: "Mavericks",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79694507892193,
                                                       longitude: -117.25456060796013),
                    radius: 48.87),
        BarBoundary(name: "710 Beach Club",
                    coordinate: CLLocationCoordinate2D(latitude: 32.7965104706228,
                                                       longitude: -117.25646435160662),
                    radius: 39.09),
        BarBoundary(name: "Alehouse",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79438673809925,
                                                       longitude: -117.25537709419827),
                    radius: 20.40),
        BarBoundary(name: "Lahaina Beach House",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79173353158148,
                                                       longitude: -117.25517734571487),
                    radius: 49.19),
        BarBoundary(name: "Society PB",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79752140560295,
                                                       longitude: -117.25066880308482),
                    radius: 20.35),
        BarBoundary(name: "Moonshine Beach",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79799945545314,
                                                       longitude: -117.24845636191166),
                    radius: 71.30),
        BarBoundary(name: "The Duck Dive",
                    coordinate: CLLocationCoordinate2D(latitude: 32.798556818044425,
                                                       longitude: -117.25626234639716),
                    radius: 10.07),
        BarBoundary(name: "Dirty Birds PB",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79875178990558,
                                                       longitude: -117.25632122341014),
                    radius: 10.07),
        BarBoundary(name: "Pacific Lounge",
                    coordinate: CLLocationCoordinate2D(latitude: 32.797448368107,
                                                       longitude: -117.25223386141543),
                    radius: 24.04),
        BarBoundary(name: "PB Avenue",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79792746127795,
                                                       longitude: -117.25064387779756),
                    radius: 20.35),
        BarBoundary(name: "Bar Ella",
                    coordinate: CLLocationCoordinate2D(latitude: 32.797808995113556,
                                                       longitude: -117.251199727816),
                    radius: 24.12),
        BarBoundary(name: "Thrusters Lounge",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79822126903441,
                                                       longitude: -117.25585450265255),
                    radius: 16.23),
        BarBoundary(name: "The Grass Skirt",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79556339183297,
                                                       longitude: -117.25280673917013),
                    radius: 76.79),
        BarBoundary(name: "Riptides PB",
                    coordinate: CLLocationCoordinate2D(latitude: 32.795913727284045,
                                                       longitude: -117.25102928653453),
                    radius: 76.79),
        BarBoundary(name: "Break Point",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79709424196353,
                                                       longitude: -117.25262000892494),
                    radius: 24.04),
        BarBoundary(name: "Waterbar",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79393763764441,
                                                       longitude: -117.25568880504693),
                    radius: 15.24),
        BarBoundary(name: "Tap Room",
                    coordinate: CLLocationCoordinate2D(latitude: 32.79830577170787,
                                                       longitude: -117.24664621336298),
                    radius: 8.07),
        BarBoundary(name: "The Collective",
                    coordinate: CLLocationCoordinate2D(latitude: 32.7983731693196,
                                                       longitude: -117.24682047353912),
                    radius: 8.07),
        BarBoundary(name: "Baja Beach Cafe",
                    coordinate: CLLocationCoordinate2D(latitude: 32.793322191294415,
                                                       longitude: -117.25567834010458),
                    radius: 30.80),
        BarBoundary(name: "Bare Back Grill",
                    coordinate: CLLocationCoordinate2D(latitude: 32.798274966357184,
                                                       longitude: -117.25623510971276),
                    radius: 14.15),
    ]
}
