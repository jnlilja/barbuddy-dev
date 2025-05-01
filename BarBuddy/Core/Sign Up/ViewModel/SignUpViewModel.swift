//
//  SignUpViewModel.swift
//  BarBuddy
//

import Foundation
import FirebaseAuth
import UIKit

@MainActor
@Observable // A more efficent way than standard stateObject/environmentObject
final class SignUpViewModel {
    // ───────── UI‑bound fields ─────────
    var email            = ""
    var newUsername      = ""
    var newPassword      = ""
    var confirmPassword  = ""

    var firstName        = ""
    var lastName         = ""
    var dateOfBirth      = ""
    var gender           = ""          // added for GenderView
    var hometown         = ""
    var jobOrUniversity  = ""
    var favoriteDrink    = ""
    var profilePictures  = [ProfilePictures(image: "https://media.istockphoto.com/id/1388645967/photo/pensive-thoughtful-contemplating-caucasian-young-man-thinking-about-future-planning-new.jpg?s=612x612&w=0&k=20&c=Keax_Or9RivnYV_9VoOLjknWQP8iaxYXc4jS9rwBmcc=", isPrimary: true, uploadedAt: "")]
    var doesntDrink      = false       // added for DrinkPreferenceView
    var sexualPreference = "straight"
    
    // ───────── Validation state ─────────
    var isValidEmail     = true
    var isValidPassword  = true
    var passwordsMatch   = true
    var alertMessage     = ""
    var showingAlert     = false
    
    func buildProfile() -> CreateUserRequest {
        CreateUserRequest(
            username: newUsername,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: newPassword,
            confirmPassword: newPassword,
            dateOfBirth: dateOfBirth,
            hometown: hometown,
            jobOrUniversity: jobOrUniversity,
            favoriteDrink: favoriteDrink,
            accountType: "regular",
            sexualPreference: "straight",
            phoneNumber: generatePhoneNumber() // Placeholder
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
    }
    
//    func convertUIImageToString(picture: UIImage) {
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let fileName = UUID().uuidString
//        let imageData = picture.jpegData(compressionQuality: 0.5)
//        let fileURL = tempDirectory.appendingPathComponent("\(fileName).jpg")
//            
//        do {
//            try imageData?.write(to: fileURL)
//            self.profilePictures = fileURL.absoluteString
//        } catch {
//            print("Error writing image to disk: \(error)")
//        }
//    }
    private func generatePhoneNumber() -> String {
        let randomDigits = (0..<10).map { _ in Int.random(in: 0...9) }
        return randomDigits.map(String.init).joined()
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

extension Date {

 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}
