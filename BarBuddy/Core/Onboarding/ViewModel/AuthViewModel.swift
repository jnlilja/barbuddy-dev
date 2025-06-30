//
//  AuthViewModel.swift
//  BarBuddy
//
//
//

import Foundation
import CryptoKit
@preconcurrency import FirebaseAuth
import AuthenticationServices
import FirebaseCore
@preconcurrency import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authUser: FirebaseAuth.User?
    @Published var currentUser: GetUser?
    @Published var showingAlert = false
    @Published var signUpAlert = false
    @Published private var errorMessage = ""
    private var currentNonce: String?
    
    init() {
        self.authUser = Auth.auth().currentUser
    }
    
    // MARK: - Sign‑in (existing account)
    func signIn(email: String, password: String) async throws {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Email and password are required."
            showingAlert = true
            throw NSError(domain: "ValidationError", code: 1001, userInfo: nil)
        }
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.authUser = result.user
        } catch let error as NSError where error.domain == AuthErrorDomain {
            // Firebase releated errors
            switch AuthErrorCode(rawValue: error.code) {
            case .invalidCredential:
                errorMessage = "Invalid email or password. Please try again."
            case .networkError:
                errorMessage = "Connection timed out. Check your internet connection and try again."
            default:
                errorMessage = error.localizedDescription
            }
            showingAlert = true
            throw error
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            // Network related errors
            switch error.code {
            case NSURLErrorNetworkConnectionLost:
                errorMessage = "Network connection lost. Check your internet connection and try again."
            case NSURLErrorNotConnectedToInternet:
                errorMessage = "You are not connected to the internet."
            default:
                errorMessage = "An unknown network error occurred. Please try again later."
            }
            showingAlert = true
            throw error
        } catch {
            errorMessage = "An unknown error occurred. Please try again later."
            showingAlert = true
            throw error
        }
    }
    
    // MARK: - Sign‑up (new account)
    /// Creates a Firebase Auth account and stores the profile in your backend.
    func signUp(profile: User, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: profile.email, password: password)
            self.authUser = result.user
        } catch let nsError as NSError where nsError.domain == AuthErrorDomain {
            // Handle Firebase Auth errors
            switch AuthErrorCode(rawValue: nsError.code) {
            case .emailAlreadyInUse:
                errorMessage = "Email is already in use. If you want to link an existing account, please sign in instead and go to your profile settings."
            case .networkError:
                errorMessage = "Network error occurred. Please try again."
            default:
                errorMessage = "Sign‑up failed: \(nsError.localizedDescription)"
            }
            showingAlert = true
        } catch {
            // Handle other errors
            errorMessage = "Sign‑up failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // Overloaded signUp method for email and password
    func signUp(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.authUser = result.user
        } catch let nsError as NSError where nsError.domain == AuthErrorDomain {
            // Handle Firebase Auth errors
            switch AuthErrorCode(rawValue: nsError.code) {
            case .emailAlreadyInUse:
                errorMessage = "Email is already in use. If you want to link an existing account, please sign in instead and go to your profile settings."
            case .networkError:
                errorMessage = "Network error occurred. Please try again."
            default:
                errorMessage = "Sign‑up failed: \(nsError.localizedDescription)"
            }
            signUpAlert = true
        } catch {
            // Handle other errors
            errorMessage = "Sign‑up failed: \(error.localizedDescription)"
            signUpAlert = true
        }
    }
    
    // MARK: - Sign‑out
    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            authUser = nil
            currentUser = nil
        } catch {
            #if DEBUG
            print("❌ Sign‑out failed:", error.localizedDescription)
            #endif
        }
    }
    
    /// Users login without creating an account
    func anonymousLogin() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            self.authUser = result.user
            
        } catch {
#if DEBUG
            print("❌ Anonymous login failed:", error.localizedDescription)
#endif
        }
    }
    
    // MARK: Apple Sign-In
    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)  // Return the hashed nonce for Apple
    }
    
    func signInWithApple(_ authorization: ASAuthorization) async {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                errorMessage = "Invalid state: A login callback was received, but no login request was sent."
                showingAlert = true
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                errorMessage = "Unable to fetch identity token"
                showingAlert = true
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = "Unable to serialize token string from data"
                showingAlert = true
                return
            }
            
            do {
                // Initialize a Firebase credential, including the user's full name.
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)
                // Sign in with Firebase.
                let result = try await Auth.auth().signIn(with: credential)
                self.authUser = result.user
            } catch {
                errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    // Only used for Apple sign in since it's required to generate a nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }

    // Encrypt random generated nonce for Apple sign in
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: Google Sign-In
    
    func signInWithGoogle() async throws {
        let credential = try await getGoogleCredential()
        let result = try await Auth.auth().signIn(with: credential)
        self.authUser = result.user
    }
    
    private func getGoogleCredential() async throws -> AuthCredential {
        // Get Firebase client ID
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw APIError.noToken
        }
        
        // Create Google Sign In configuration
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get root view controller
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            throw APIError.noToken
        }
        
        // Perform Google Sign In for reauthentication
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        let googleUser = result.user
        guard let idToken = googleUser.idToken?.tokenString else {
            throw APIError.noToken
        }
        
        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleUser.accessToken.tokenString
        )
    
        return credential
    }
    
    func reauthenticateWithGoogle() async throws {
        guard let user = authUser else {
            throw APIError.noToken
        }
        let credential = try await getGoogleCredential()
        
        // Reauthenticate with Firebase
        try await user.reauthenticate(with: credential)
    }
    
    // MARK: Reauthenticate
    
    func reauthenticate(password: String) async throws {
        guard let user = authUser, let email = user.email else {
            throw APIError.noToken
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    // MARK: Delete User
    
    func deleteUser(password: String) async throws {
        guard let user = authUser else {
            throw APIError.noToken
        }
        
        // Credentials expire after 5 minutes
        if let lastSignInDate = user.metadata.lastSignInDate,
            lastSignInDate < Date(timeInterval: -300, since: Date()) {
            try await reauthenticate(password: password)
        }
        
        try await user.delete()
        authUser = nil
        currentUser = nil
    }
    
    // Should be used for Google auth
    func deleteUser() async throws {
        guard let user = authUser else {
            throw APIError.noToken
        }
        
        try await user.delete()
        try await GIDSignIn.sharedInstance.disconnect()
        authUser = nil
        currentUser = nil
    }
    
    // MARK: Link Accounts
    
    func linkMultipleAccounts(credential: AuthCredential) async {
        guard self.authUser != nil else { return }
        do {
            let result = try await self.authUser?.link(with: credential)
            self.authUser = result?.user
            
        } catch let error as NSError where error.domain == AuthErrorDomain {
            switch AuthErrorCode(rawValue: error.code) {
                
            case .providerAlreadyLinked:
                errorMessage = "Provider already linked to another account."
                
            case .credentialAlreadyInUse:
                errorMessage = "Credential already in use by another account."
                
            case .operationNotAllowed:
                errorMessage = "Account linking is not enabled for this sign-in provider."
                
            case .requiresRecentLogin:
                errorMessage = "You need to re-authenticate before you can link multiple accounts."
                
            case .emailAlreadyInUse:
                errorMessage = "Email address is already in use by another account."
                
            default:
                errorMessage = "Unexpected error occurred while linking accounts."
            }
            
            showingAlert = true
        } catch {
            errorMessage = "Unexpected error occurred while linking accounts."
            showingAlert = true
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String) async {
        guard let user = authUser, let email = user.email else {
            return
        }
        
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            print(error.localizedDescription)
            errorMessage = "Unexpected error occurred while changing password."
            showingAlert = true
        }
    }
    
    func sendPasswordResetEmail(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = "Unexpected error occurred while sending password reset email."
            showingAlert = true
        }
    }
    
    func getCurrentProviderType() -> String? {
        return authUser?.providerData.first?.providerID
    }
    
    func getErrorMessage() -> String {
        return errorMessage
    }
}
