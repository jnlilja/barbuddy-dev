//
//  LoginViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import Foundation

// This viewModel handles the logic of validation and posting changes to UI
@Observable
class SignUpViewModel: CustomStringConvertible {
    var email: String = ""
    var password: String = ""
    var newUsername: String = ""
    var confirmPassword: String = ""
    var isValidEmail: Bool = true
    var isValidPassword: Bool = true
    var showingAlert = false
    var alertMessage = ""
    var name: String = ""
    var age: Int = -1
    var height: String = ""
    var hometown: String = ""
    var school: String = ""
    var favoriteDrink: String = ""
    var preference: String = ""
    var bio: String = ""
    var imageNames: [String] = []
    var gender: String = ""
    
    // For testing purposes
    public var description: String {
        return """
            Data for \(newUsername):
            
            email: \(email)
            password: \(password)
            name: \(name)
            age: \(age)
            """
    }
    
    // Add variables for validation
    var passwordsMatch = true
    var showingAgeVerification = false
    
    func validateAndSignUp() {
        // Reset validation states
        isValidEmail = true
        isValidPassword = true
        passwordsMatch = true
        
        // Validate email
        if !isValidEmailFormat(email) {
            isValidEmail = false
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }
        
        // Validate username
        if newUsername.count < 3 {
            alertMessage = "Username must be at least 3 characters long"
            showingAlert = true
            return
        }
        
        // Validate password
        if !isValidPasswordFormat(password) {
            isValidPassword = false
            alertMessage = "Password must be at least 8 characters with a number and special character"
            showingAlert = true
            return
        }
        
        // Check if passwords match
        if password != confirmPassword {
            passwordsMatch = false
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        // If all validations pass
        if !showingAlert {
            showingAgeVerification = true  // Show age verification instead of dismissing
        }
    }
    
    // Regex for email
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Regex for user password
    private func isValidPasswordFormat(_ password: String) -> Bool {
        // At least 8 characters
        // Contains at least one number
        // Contains at least one special character
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
