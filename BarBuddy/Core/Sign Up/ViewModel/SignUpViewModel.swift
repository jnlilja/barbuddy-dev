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
    
    func buildProfile() -> SignUpUser {
        SignUpUser(
                username: newUsername,
                first_name: firstName,
                last_name: lastName,
                email: email,
                password: newPassword,
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

    // MARK: - Public entry point from the UI
    func validateAndSignUp() -> Bool {
        // 1) Basic client‑side validation
        guard isValidEmailFormat(email) else {
            fire("Please enter a valid email.")
            return false
        }
        guard newUsername.count >= 3 else {
            fire("Username must be ≥ 3 characters.")
            return false
        }
        guard isValidPasswordFormat(newPassword) else {
            fire("Password must be ≥ 8 characters with a number & special char.")
            return false
        }
        guard newPassword == confirmPassword else { fire("Passwords do not match.")
            return false
        }
        
        return true

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
        
        //await signUp(profile: profile)
//
//        Task {
//            await signUp(profile: profile)
//        }
    }

    // MARK: - Sign‑up flow
    private func signUp(profile: PostUser) async {
        do {
            // 1) Create Firebase Auth account
//            _ = try await Auth.auth().createUser(withEmail: profile.email,
//                                                 password: profile.password)

            // 2) Send profile JSON to your API
            
            //TODO: - refactor to SignupUser
            //let result = await PostUserAPIService.shared.register(user: profile)
            
//            switch result {
//            case .success(let success):
//                //load ID token
//                
//                print("✅ New user created & stored.")
//            case .failure(let failure):
//                print("an error occured")
//                alertMessage = "Sign up failed"
//                showingAlert = true
//            }
            
//            try await PostUserAPIService.shared.create(user: profile)
//
//            alertMessage = "Account created successfully!"
//            showingAlert = true
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
