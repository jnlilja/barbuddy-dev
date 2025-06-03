//
//  SampleBar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/2/25.
//

import Foundation

extension Bar {
    static let sampleBar = Bar(
        id: 1,
        name: "The Rusty Nail",
        address: "123 Main Street, Austin, TX 78701",
        averagePrice: "$$",
        location: Location(latitude: 30.267153, longitude: -97.743057),
        usersAtBar: [101, 102, 103],
        currentStatus: CurrentStatus(
            crowdSize: 45,
            waitTime: 15,
            lastUpdated: Date()
        ),
        averageRating: 4.7,
        images: [
            BarImage(id: 1, bar: 1, image: "https://images.unsplash.com/photo-1514933651103-005eec06c04b?q=80&w=1974&auto=format&fit=crop", caption: "Test"),
            BarImage(id: 2, bar: 2, image: "https://images.unsplash.com/photo-1572116469696-31de0f17cc34?q=80&w=1974&auto=format&fit=crop", caption: "Test")
        ],
        currentUserCount: 87,
        activityLevel: "Busy"
    )
    
    static let sampleBars = [
        sampleBar,
        Bar(
            id: 2,
            name: "The Whiskey Lounge",
            address: "456 Congress Ave, Austin, TX 78701",
            averagePrice: "$$$",
            location: Location(latitude: 30.268736, longitude: -97.742088),
            usersAtBar: [104, 105],
            currentStatus: CurrentStatus(
                crowdSize: 30,
                waitTime: 5,
                lastUpdated: Date().addingTimeInterval(-1800)
            ),
            averageRating: 4.2,
            images: [
                BarImage(id: 3, bar: 3, image: "https://images.unsplash.com/photo-1470337458703-46ad1756a187?q=80&w=1969&auto=format&fit=crop", caption: "Test")
            ],
            currentUserCount: 42,
            activityLevel: "Moderate"
        ),
        Bar(
            id: 3,
            name: "Sixth Street Pub",
            address: "789 Sixth St, Austin, TX 78701",
            averagePrice: "$",
            location: Location(latitude: 30.267612, longitude: -97.738903),
            usersAtBar: [],
            currentStatus: CurrentStatus(
                crowdSize: 75,
                waitTime: 30,
                lastUpdated: Date().addingTimeInterval(-600)
            ),
            averageRating: 3.9,
            images: [
                BarImage(id: 4, bar: 4, image: "https://images.unsplash.com/photo-1546854810-9fd5bdcd1ad6?q=80&w=2070&auto=format&fit=crop", caption: "Test"),
                BarImage(id: 5, bar: 5, image: "https://images.unsplash.com/photo-1541655335827-3e49c45616ad?q=80&w=2070&auto=format&fit=crop", caption: nil)
            ],
            currentUserCount: 120,
            activityLevel: "Very busy"
        )
    ]
}
