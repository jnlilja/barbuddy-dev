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
    @Published var newPassword      = ""
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
    
    func buildProfile() -> PostUser {
            PostUser(
                username: newUsername,
                first_name: firstName,
                last_name: lastName,
                email: email,
                password: newPassword,
                date_of_birth: dateOfBirth,
                hometown: hometown,
                job_or_university: jobOrUniversity,
                favorite_drink: favoriteDrink,
                profile_pictures: [:],
                account_type: "regular",
                sexual_preference: sexualPreference
            )
        }

    // MARK: - Public entry point from the UI
    func validateAndSignUp() {
        // 1) Basic client‑side validation
        guard isValidEmailFormat(email) else { return fire("Please enter a valid email.") }
        guard newUsername.count >= 3 else { return fire("Username must be ≥ 3 characters.") }
        guard isValidPasswordFormat(newPassword) else {
            return fire("Password must be ≥ 8 characters with a number & special char.")
        }
        guard newPassword == confirmPassword else { return fire("Passwords do not match.") }

        // 2) Build profile & call Auth + API
//        let profile = PostUser(
//            username: newUsername,
//            first_name: firstName,
//            last_name: lastName,
//            email: email,
//            password: newPassword,      // store hashed in backend, plain here only to send
//            date_of_birth: dateOfBirth,
//            hometown: hometown,
//            job_or_university: jobOrUniversity,
//            favorite_drink: favoriteDrink,
//            profile_pictures: [:],
//            account_type: "regular",
//            sexual_preference: sexualPreference
//        )
//
//        Task {
//            await signUp(profile: profile)
//        }
    }

    // MARK: - Sign‑up flow
    private func signUp(profile: PostUser) async {
        do {
            // 1) Create Firebase Auth account
            _ = try await Auth.auth().createUser(withEmail: profile.email,
                                                 password: profile.password)

            // 2) Send profile JSON to your API
            try await PostUserAPIService.shared.create(user: profile)

            alertMessage = "Account created successfully!"
            showingAlert = true
        } catch {
            fire(error.localizedDescription)
        }
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
    private func fire(_ message: String) {
        alertMessage  = message
        showingAlert  = true
    }
}
