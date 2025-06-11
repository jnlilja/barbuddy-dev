//
//  SignUpViewModel.swift
//  BarBuddy
//

import Foundation
import FirebaseAuth

@Observable final class SignUpViewModel {
    // ───────── UI‑bound fields ─────────
    var email            = ""
    var newUsername      = ""
    var password         = ""
    var confirmPassword  = ""

    var firstName        = ""
    var lastName         = ""
    var dateOfBirth      = ""
    var gender           = ""          // added for GenderView
    var hometown         = ""
    var jobOrUniversity  = ""
    var favoriteDrink    = ""
    var doesntDrink      = false       // added for DrinkPreferenceView
    var sexualPreference = "straight"
    
    // ───────── Validation state ─────────
    @ObservationIgnored var isValidEmail     = true
    @ObservationIgnored var isValidPassword  = true
    @ObservationIgnored var passwordsMatch   = true
    @ObservationIgnored var alertMessage     = ""
    var showingAlert     = false
    
    typealias ValidationChecks = [(Bool, String)]
    
    func buildProfile() -> SignUpUser {
        SignUpUser(
                username: newUsername,
                first_name: firstName,
                last_name: lastName,
                email: email,
                password: password,
                confirm_password: confirmPassword,
                date_of_birth: dateOfBirth,
                hometown: hometown,
                job_or_university: jobOrUniversity,
                favorite_drink: favoriteDrink,
                profile_pictures: [:],
                account_type: "regular",
                sexual_preference: sexualPreference
            )
        }

    func validate() -> Bool {
        let checks: ValidationChecks = [
          (isValidEmailFormat(email),       "Please enter a valid email."),
          (isValidPasswordFormat(password), "Password must be at least 8 characters with a number & special character."),
          (password == confirmPassword,     "Passwords do not match.")
        ]

        for (passes, message) in checks {
          guard passes else {
            error(message)
            return false
          }
        }
        return true
    }


    // MARK: - Helpers
    private func isValidEmailFormat(_ str: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    private func isValidPasswordFormat(_ str: String) -> Bool {
        let regex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    private func error(_ message: String) {
        alertMessage  = message
        showingAlert  = true
    }
}
