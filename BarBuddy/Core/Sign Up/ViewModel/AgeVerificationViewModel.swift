//
//  AgeVerificationViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import Foundation

@Observable
final class AgeVerificationViewModel {
    var dateOfBirth = Date()
    var showingAgeAlert = false
    var proceedToName = false
    
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
