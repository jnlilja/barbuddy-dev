//
//  LoginViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import Foundation

// This viewModel handles the logic of validation and posting changes to UI
class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var newUsername: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isValidEmail: Bool = true
    @Published var isValidPassword: Bool = true
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
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
        if !isValidPasswordFormat(newPassword) {
            isValidPassword = false
            alertMessage = "Password must be at least 8 characters with a number and special character"
            showingAlert = true
            return
        }
        
        // Check if passwords match
        if newPassword != confirmPassword {
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
