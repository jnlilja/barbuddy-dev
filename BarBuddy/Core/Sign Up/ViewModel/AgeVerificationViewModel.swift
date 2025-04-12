//
//  AgeVerificationViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import Foundation

final class AgeVerificationViewModel: ObservableObject {
    @Published var dateOfBirth = Date()
    @Published var showingAgeAlert = false
    @Published var proceedToName = false
    
    func verifyAge() -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        
        if age >= 21 {
            proceedToName = true
        } else {
            showingAgeAlert = true
        }
        return age
    }
    
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: dateOfBirth)
    }
}
