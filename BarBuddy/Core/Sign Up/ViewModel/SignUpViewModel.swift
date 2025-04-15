import Foundation

@Observable
class SignUpViewModel: ObservableObject {
    // Sign up fields already present
    var email: String = ""
    var newUsername: String = ""
    var newPassword: String = ""
    var confirmPassword: String = ""
    
    // Additional fields (if your UI collects these)
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: String = ""
    var hometown: String = ""
    var jobOrUniversity: String = ""
    var favoriteDrink: String = ""
    
    // Validation and state variables
    var isValidEmail: Bool = true
    var isValidPassword: Bool = true
    var showingAlert = false
    var alertMessage = ""
    var passwordsMatch = true
    var showingAgeVerification = false
    
    // Instance of the PostUserViewModel (to make the API call)
    private let postUserVM = PostUserViewModel()
    
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
        
        // Validate password format
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
        
        // If everything validates and if you’re ready to proceed (or after age verification),
        // call signUpUser() to create the API call.
        if !showingAlert {
            signUpUser()
        }
    }
    
    // Constructs a PostUser instance and calls the API to create the new user.
    func signUpUser() {
        let newUser = PostUser(
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
            account_type: "regular"
        )
        
        // Use the PostUserViewModel to send the request
        postUserVM.postUser(newUser: newUser)
    }
    
    // Regex for validating email format.
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Regex for validating password format.
    private func isValidPasswordFormat(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
