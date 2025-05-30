//
//  SignUpViewModel.swift
//  BarBuddy
//

import Foundation
import FirebaseAuth

@MainActor
final class SignUpViewModel: ObservableObject {
    // ───────── UI‑bound fields ─────────
    @Published var email            = ""
    @Published var newUsername      = ""
    @Published var password         = ""
    @Published var confirmPassword  = ""

    @Published var firstName        = ""
    @Published var lastName         = ""
    @Published var dateOfBirth      = ""
    @Published var gender           = ""          // added for GenderView
    @Published var hometown         = ""
    @Published var jobOrUniversity  = ""
    @Published var favoriteDrink    = ""
    @Published var doesntDrink      = false       // added for DrinkPreferenceView
    @Published var sexualPreference = "straight"
    
    // ───────── Validation state ─────────
    @Published var isValidEmail     = true
    @Published var isValidPassword  = true
    @Published var passwordsMatch   = true
    @Published var alertMessage     = ""
    @Published var showingAlert     = false
    
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

    func validateAndSignUp() -> Bool {
        let checks: [(Bool, String)] = [
          (isValidEmailFormat(email),              "Please enter a valid email."),
          (newUsername.count >= 3,                 "Username must be at least 3 characters."),
          (isValidPasswordFormat(password),     "Password must be at least 8 characters with a number & special character."),
          (password == confirmPassword,         "Passwords do not match.")
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
