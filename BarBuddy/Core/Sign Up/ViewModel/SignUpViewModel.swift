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
    @Published var isLoading        = false
    @Published var error            = ""
    @Published var isSignedUp       = false
    
    let baseURL = URL(string: "barbuddy-backend-148659891217.us-central1.run.app/api")!
    
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
            favorite_drink: doesntDrink ? "Doesn't drink" : favoriteDrink,
            profile_pictures: [:],
            account_type: "regular",
            sexual_preference: gender.lowercased() == "male" ? "straight" : sexualPreference
        )
    }

    // MARK: - Public entry point from the UI
    func validateAndSignUp() async {
        guard !isLoading else { return }
        
        // Reset error state
        error = nil
        
        // Validate required fields
        guard !newUsername.isEmpty else {
            error = "Username is required"
            return
        }
        
        guard !email.isEmpty else {
            error = "Email is required"
            return
        }
        
        guard !newPassword.isEmpty else {
            error = "Password is required"
            return
        }
        
        guard !confirmPassword.isEmpty else {
            error = "Please confirm your password"
            return
        }
        
        guard newPassword == confirmPassword else {
            error = "Passwords do not match"
            return
        }
        
        guard isValidPasswordFormat(newPassword) else {
            error = "Password must be at least 8 characters and contain a number and special character"
            return
        }
        
        guard !dateOfBirth.isEmpty else {
            error = "Date of birth is required"
            return
        }
        
        // Validate date format
        guard isValidDateFormat(dateOfBirth) else {
            error = "Date must be in YYYY-MM-DD format"
            return
        }
        
        // Validate age
        guard isOver18(dateOfBirth) else {
            error = "You must be at least 18 years old"
            return
        }
        
        // Validate email format
        guard isValidEmailFormat(email) else {
            error = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        
        do {
            // First create Firebase account
            let authResult = try await Auth.auth().createUser(withEmail: email, password: newPassword)
            
            // Update Firebase user profile
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            try await changeRequest.commitChanges()
            
            // Then create user in our backend
            let user = buildProfile()
            try await PostUserAPIService.shared.create(user: user)
            
            // Update additional user info
            let userInfo: [String: Any] = [
                "date_of_birth": user.date_of_birth,
                "hometown": user.hometown,
                "job_or_university": user.job_or_university,
                "favorite_drink": user.favorite_drink,
                "sexual_preference": user.sexual_preference
            ]
            try await GetUserAPIService.shared.updateUserInfo(userInfo: userInfo)
            
            isSignedUp = true
        } catch let error as APIError {
            switch error {
            case .validation(let message):
                self.error = message
            case .conflict(let message):
                self.error = message
            case .unauthorized:
                self.error = "Authentication failed. Please try again."
            case .noToken:
                self.error = "Please sign in with Firebase first."
            default:
                self.error = "An error occurred. Please try again."
            }
        } catch let error as NSError {
            if error.domain == AuthErrorDomain {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self.error = "This email is already in use"
                case AuthErrorCode.weakPassword.rawValue:
                    self.error = "Password is too weak"
                case AuthErrorCode.invalidEmail.rawValue:
                    self.error = "Invalid email format"
                default:
                    self.error = "Firebase error: \(error.localizedDescription)"
                }
            } else {
                self.error = "An unexpected error occurred. Please try again."
            }
        } catch {
            self.error = "An unexpected error occurred. Please try again."
        }
        
        isLoading = false
    }

    // MARK: - Sign‑up flow
    private func signUp(profile: PostUser) async throws {
        // 1) Create Firebase Auth account
        let authResult = try await Auth.auth().createUser(withEmail: profile.email,
                                                        password: profile.password)
        
        // 2) Update Firebase user profile
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = "\(profile.first_name) \(profile.last_name)"
        try await changeRequest.commitChanges()
        
        // 3) Send profile JSON to your API
        try await PostUserAPIService.shared.create(user: profile)
        
        // 4) Update additional user information
        let userInfo: [String: Any] = [
            "date_of_birth": profile.date_of_birth,
            "hometown": profile.hometown,
            "job_or_university": profile.job_or_university,
            "favorite_drink": profile.favorite_drink,
            "sexual_preference": profile.sexual_preference
        ]
        try await GetUserAPIService.shared.updateUserInfo(userInfo: userInfo)
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
    
    private func isValidDateFormat(_ str: String) -> Bool {
        let regex = "^\\d{4}-\\d{2}-\\d{2}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    
    private func isOver18(_ dateStr: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let birthDate = dateFormatter.date(from: dateStr) else { return false }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
    
    private func fire(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
