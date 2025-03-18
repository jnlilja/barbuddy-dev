//
//  ContentView.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
import PhotosUI  // Add this for photo picker

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername: Float = 0
    @State private var wrongPassword: Float = 0
    @State private var showingLoginScreen = false
    @State private var showingSignUpSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(Color("Nude")).opacity(0.15)
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white).opacity(0.9)

                VStack {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("DarkPurple"))
                        .padding(.bottom, 20)
                    
                    Text("BarBuddy")
                        .font(.largeTitle)
                        .foregroundColor(Color("DarkPurple"))
                        .bold()
                    
                    Text("Know Before You Go")
                        .font(.subheadline)
                        .foregroundColor(Color("DarkPurple"))
                        .padding(.bottom, 50)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("DarkPurple"), lineWidth: 1)
                        )
                        .border(.red, width: CGFloat(wrongUsername))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("DarkPurple"), lineWidth: 1)
                        )
                        .border(.red, width: CGFloat(wrongPassword))
                        .padding(.top, 10)
                    
                    Button(action: {
                        authenticateUser(username: username, password: password)
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                    
                    Button(action: {
                        showingSignUpSheet = true
                    }) {
                        Text("Don't have an account? Sign up")
                            .font(.subheadline)
                            .foregroundColor(Color("DarkPurple"))
                    }
                    .padding(.top, 15)
                    
                    NavigationLink(destination: Text("You are logged in, \(username)"), isActive: $showingLoginScreen) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUpSheet) {
                SignUpView(isPresented: $showingSignUpSheet)
            }
        }
    }
    
    func authenticateUser(username: String, password: String) {
        if username.lowercased() == "mario2021" {
            wrongUsername = 0
            if password.lowercased() == "abc123" {
                wrongPassword = 0
                showingLoginScreen = true
            } else {
                wrongPassword = 2
            }
        } else {
            wrongUsername = 2
        }
    }
}

struct SignUpView: View {
    @Binding var isPresented: Bool
    @State private var newUsername = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    
    // Add state variables for validation
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var passwordsMatch = true
    @State private var showingAgeVerification = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.bottom, 30)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isValidEmail ? Color("DarkPurple") : .red, lineWidth: 1)
                        )
                        .autocapitalization(.none)
                    
                    TextField("Username", text: $newUsername)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $newPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isValidPassword ? Color("DarkPurple") : .red, lineWidth: 1)
                        )
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(passwordsMatch ? Color("DarkPurple") : .red, lineWidth: 1)
                        )
                    
                    if !isValidPassword {
                        Text("Password must be at least 8 characters with a number and special character")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        validateAndSignUp()
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(.white))
            .alert("Sign Up Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .fullScreenCover(isPresented: $showingAgeVerification) {
                AgeVerificationView()
            }
        }
    }
    
    // Add validation functions
    private func validateAndSignUp() {
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
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPasswordFormat(_ password: String) -> Bool {
        // At least 8 characters
        // Contains at least one number
        // Contains at least one special character
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("DarkPurple"), lineWidth: 1)
            )
    }
}

struct AgeVerificationView: View {
    @State private var dateOfBirth = Date()
    @State private var showingAgeAlert = false
    @State private var proceedToName = false
    
    private var minimumDate: Date {
        Calendar.current.date(byAdding: .year, value: -120, to: Date()) ?? Date()
    }
    
    private var maximumDate: Date {
        Date()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("Verify Your Age")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                    
                    Text("You must be 21 or older to use BarBuddy")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: minimumDate...maximumDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding()
                    
                    Button(action: {
                        verifyAge()
                    }) {
                        Text("Verify Age")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: NameEntryView(), isActive: $proceedToName) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .alert("Age Verification Failed", isPresented: $showingAgeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You must be 21 or older to use BarBuddy.")
            }
            .navigationBarHidden(true)
        }
    }
    
    private func verifyAge() {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        
        if age >= 21 {
            proceedToName = true
        } else {
            showingAgeAlert = true
        }
    }
}

struct NameEntryView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var proceedToLocation = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 0, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("What's Your Name?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        proceedToLocation = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                    .opacity(firstName.isEmpty || lastName.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToLocation) {
            LocationView(currentStep: .constant(0))
        } label: {
            EmptyView()
        }
    }
}

struct LocationView: View {
    @Binding var currentStep: Int
    @State private var proceedToProfileSetup = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 1, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Where are you located?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Beta Version: Currently available for Pacific Beach, San Diego select bars only")
                        .font(.headline)
                        .foregroundColor(Color("Salmon"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("We're starting small to ensure the best experience! More locations coming soon.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        proceedToProfileSetup = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToProfileSetup) {
            GenderView()
        } label: {
            EmptyView()
        }
    }
}

struct ProgressDots: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color("Salmon") : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 30)
    }
}

struct GenderView: View {
    @State private var selectedGender: String?
    @State private var proceedToNextPage = false
    
    let genderOptions = ["Man", "Woman", "Non-binary", "Prefer not to say"]
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 2, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("What's your gender?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        ForEach(genderOptions, id: \.self) { gender in
                            Button(action: {
                                selectedGender = gender
                            }) {
                                Text(gender)
                                    .bold()
                                    .frame(width: 300, height: 50)
                                    .background(selectedGender == gender ? Color("DarkPurple") : Color("Salmon"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Text("BarBuddy is for making friends! You'll see both men and women in your area, but you can adjust your preferences later.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(selectedGender == nil)
                    .opacity(selectedGender == nil ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            HometownView()
        } label: {
            EmptyView()
        }
    }
}

struct HometownView: View {
    @State private var hometown = ""
    @State private var showOnProfile = true
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 3, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Where are you from?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    TextField("Enter your hometown", text: $hometown)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        showOnProfile.toggle()
                    }) {
                        HStack {
                            Image(systemName: showOnProfile ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("Show on my profile")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(hometown.isEmpty)
                    .opacity(hometown.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            SchoolView()
        } label: {
            EmptyView()
        }
    }
}

struct SchoolView: View {
    @State private var school = ""
    @State private var currentlyAttending = false
    @State private var major = ""
    @State private var showOnProfile = true
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 4, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Where did you go to school?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    TextField("Enter your school", text: $school)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        currentlyAttending.toggle()
                    }) {
                        HStack {
                            Image(systemName: currentlyAttending ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("I currently attend this school")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    if currentlyAttending {
                        TextField("What's your major?", text: $major)
                            .textFieldStyle(CustomTextFieldStyle())
                            .transition(.opacity)
                    }
                    
                    Button(action: {
                        showOnProfile.toggle()
                    }) {
                        HStack {
                            Image(systemName: showOnProfile ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("Show on my profile")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(school.isEmpty || (currentlyAttending && major.isEmpty))
                    .opacity(school.isEmpty || (currentlyAttending && major.isEmpty) ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: currentlyAttending)
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            DrinkPreferenceView()
        } label: {
            EmptyView()
        }
    }
}

struct DrinkPreferenceView: View {
    @State private var favoriteDrink = ""
    @State private var doesntDrink = false
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 5, totalPages: 7)
                
                VStack(spacing: 25) {
                    Image(systemName: "cocktail")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text("What's your drink of choice?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    if !doesntDrink {
                        TextField("Enter your favorite drink", text: $favoriteDrink)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    Button(action: {
                        doesntDrink.toggle()
                        if doesntDrink {
                            favoriteDrink = "I don't drink"
                        } else {
                            favoriteDrink = ""
                        }
                    }) {
                        HStack {
                            Image(systemName: doesntDrink ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("I don't drink 🙏")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(favoriteDrink.isEmpty)
                    .opacity(favoriteDrink.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: doesntDrink)
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            SmokingPreferenceView()
        } label: {
            EmptyView()
        }
    }
}

struct SmokingPreferenceView: View {
    @State private var smokesWeed = false
    @State private var smokesTobacco = false
    @State private var vapes = false
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 6, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Do you smoke?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            smokesWeed.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: smokesWeed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Cannabis 🍃")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                        
                        Button(action: {
                            smokesTobacco.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: smokesTobacco ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Cigarettes 🚬")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                        
                        Button(action: {
                            vapes.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: vapes ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Vape 💨")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                    }
                    .padding(.vertical, 30)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            PhotoPromptView()
        } label: {
            EmptyView()
        }
    }
}

struct PhotoPromptView: View {
    @State private var proceedToPhotoUpload = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("Salmon"))
                    .padding(.bottom, 30)
                
                Text("A Picture is Worth")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                Text("a Thousand Words")
                    .font(.title)
                    .foregroundColor(Color("Salmon"))
                    .bold()
                    .padding(.bottom, 50)
                
                Text("Add some photos to complete your profile")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    proceedToPhotoUpload = true
                }) {
                    Text("Add Photos")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToPhotoUpload) {
            PhotoUploadView()
        } label: {
            EmptyView()
        }
    }
}

struct PhotoUploadView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var proceedToHome = false
    
    let minPhotos = 4
    let maxPhotos = 6
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 50)  // Reduced top spacing
                
                Text("Add \(minPhotos)-\(maxPhotos) Photos")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                Text("\(selectedImages.count)/\(maxPhotos) photos added")
                    .foregroundColor(Color("Salmon"))
                    .padding(.vertical, 20)
                
                // Center the grid in the middle of the screen
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(0..<maxPhotos, id: \.self) { index in
                            if index < selectedImages.count {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)  // Limit scroll view height
                
                Spacer()
                
                Button(action: {
                    proceedToHome = true
                }) {
                    Text("Let's go!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .disabled(selectedImages.count < minPhotos)
                .opacity(selectedImages.count < minPhotos ? 0.6 : 1)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxPhotos: maxPhotos)
        }
        .fullScreenCover(isPresented: $proceedToHome) {
            HomeView()
        }
    }
}

// Helper struct for image picking
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxPhotos: Int
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxPhotos - selectedImages.count
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct HomeView: View {
    @State private var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SwipeView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Swipe")
                }
                .tag(0)
            
            MessagesView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
                .tag(1)
            
            MainFeedView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(2)
            
            DealsAndEventsView()
                .tabItem {
                    Image(systemName: "ticket.fill")
                    Text("Specials")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Color("Salmon"))
        .onAppear {
            // Set tab bar to be white with transparency
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct SwipeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack {
                    // Top Bar
                    HStack {
                        HStack(spacing: 4) {
                            Text("@ Hideaway")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color("Salmon").opacity(0.3))
                                .cornerRadius(25)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    // Card Stack with Side Buttons
                    ZStack {
                        ForEach(0..<3) { index in
                            SwipeCard()
                                .overlay(
                                    HStack {
                                        // Left X Button
                                        Button(action: {}) {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 54, height: 54)
                                                .shadow(radius: 5)
                                                .overlay(
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.red)
                                                )
                                        }
                                        .padding(.leading, 30)
                                        
                                        Spacer()
                                        
                                        // Right Check Button
                                        Button(action: {}) {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 54, height: 54)
                                                .shadow(radius: 5)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(Color("Salmon"))
                                                )
                                        }
                                        .padding(.trailing, 30)
                                    }
                                    .offset(y: UIScreen.main.bounds.height * 0.05)  // Changed from -0.05 to 0.05 to move buttons down
                                )
                        }
                    }
                    
                    Spacer()  // Remove bottom button section and use spacer
                }
            }
        }
    }
}

struct SwipeCard: View {
    var body: some View {
        VStack {
            // Profile Image - made taller
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: UIScreen.main.bounds.height * 0.7)  // Increased from 0.6 to 0.7
                .cornerRadius(20)
                .overlay(
                    VStack {
                        Spacer()
                        
                        // User Info Overlay
                        VStack(alignment: .leading, spacing: 12) {
                            // Name and Status
                            HStack {
                                Text("Ashley")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color("DarkPurple"))
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color("NeonPink"))
                                    .font(.system(size: 20))
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Active")
                                }
                                .foregroundColor(Color("DarkPurple"))
                            }
                            
                            // Location and Group
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Hideaway")
                                }
                                .foregroundColor(Color("DarkPurple"))
                                
                                Spacer()
                                
                                Text("Group: Golden Girls")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("Salmon").opacity(0.2))
                                    .cornerRadius(15)
                            }
                            
                            // Stats
                            HStack(spacing: 25) {
                                Label("23", systemImage: "birthday.cake")
                                Label("5'11", systemImage: "ruler")
                                Label("San Diego", systemImage: "house")
                            }
                            .font(.system(size: 16))
                            .foregroundColor(Color("DarkPurple"))
                            
                            // School and Drink
                            HStack(spacing: 25) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color("DarkPurple"))
                                        .frame(width: 25, height: 25)
                                    Text("SDSU")
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "wineglass")
                                    Text("Tequila")
                                }
                            }
                            .font(.system(size: 16))
                            .foregroundColor(Color("DarkPurple"))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                    .padding()
                )
        }
        .padding()
    }
}

struct DealsAndEventsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        Text("Deals and Events")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Events Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Events")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Event Cards
                            EventCard(
                                title: "Fish Races",
                                location: "PB Shoreclub",
                                time: "Wednesdays // 8pm - Close"
                            )
                            
                            EventCard(
                                title: "Karaoke",
                                location: "PB Local",
                                time: "Wednesdays // 7pm - 10pm"
                            )
                            
                            EventCard(
                                title: "Trivia",
                                location: "Open Bar",
                                time: "Wednesdays // 6pm - 9pm"
                            )
                        }
                        
                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Deals")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Deal Cards
                            DealCard(
                                title: "Well Wednesday",
                                location: "Open Bar",
                                description: "$5 Shots all night!"
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct EventCard: View {
    let title: String
    let location: String
    let time: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
            
            Text("@ \(location)")
                .font(.title2)
                .foregroundColor(Color("DarkPurple"))
            
            Text(time)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct DealCard: View {
    let title: String
    let location: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
            
            Text("@ \(location)")
                .font(.title2)
                .foregroundColor(Color("DarkPurple"))
            
            Text(description)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct MainFeedView: View {
    @State private var scrollOffset: CGFloat = 0
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Map View Section (stays at top)
                        MapPreviewSection()
                            .frame(height: 300)
                            .zIndex(1)
                        
                        // Scrollable content
                        VStack(spacing: 0) {
                            // Search Bar
                            SearchBar()
                                .padding()
                            
                            // Bar List
                            VStack(spacing: 20) {
                                ForEach(0..<5) { _ in
                                    BarCard(selectedTab: $selectedTab)
                                }
                            }
                            .padding()
                        }
                        .background(Color("DarkBlue"))
                        .offset(y: -scrollOffset)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = -min(value, 0)
                }
            }
            .navigationTitle("Pacific Beach")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapPreviewSection: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3) // Placeholder for map
            Text("Map View")
        }
    }
}

struct SearchBar: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("Salmon"))
            
            TextField("Search bars...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)  // Changed to pure white
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct BarListSection: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    BarCard(selectedTab: .constant(0))
                }
            }
            .padding()
        }
    }
}

struct BarCard: View {
    @State private var showingDetail = false
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            HStack {
                Text("Hideaway")
                    .font(.system(size: 32, weight: .bold))
                    .bold()
                    .foregroundColor(Color("DarkBlue"))
                
                Spacer()
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color("NeonPink"))
                        .font(.system(size: 24))
                    Text("Trending")
                        .foregroundColor(Color("DarkPurple"))
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            
            // Open Hours
            Text("Open 11am - 2am")
                .foregroundColor(Color("DarkPurple"))
            
            // Bar Image
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
            
            // Quick Info Icons
            HStack(spacing: 12) {
                InfoTag(icon: "music.note", text: "House")
                InfoTag(icon: "person.3.fill", text: "Packed")
                InfoTag(icon: "dollarsign.circle", text: "$5-20")
            }
            .frame(maxWidth: .infinity)
            
            // Action Buttons
            VStack(spacing: 10) {
                ActionButton(
                    text: "See who's there",
                    icon: "person.2.fill",
                    action: { selectedTab = 0 }
                )
                ActionButton(
                    text: "Check the line",
                    icon: "antenna.radiowaves.left.and.right",
                    action: { showingDetail = true }
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            BarDetailPopup(isPresented: $showingDetail)
        }
    }
}

struct InfoTag: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(.system(size: 14))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color("DarkPurple"))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("NeonPink"), lineWidth: 1)
        )
        .cornerRadius(15)
    }
}

struct ActionButton: View {
    let text: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("DarkPurple"))
            .cornerRadius(10)
        }
    }
}

// Login Flow Previews
struct LoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("Login")
            
            AgeVerificationView()
                .previewDisplayName("Age Check")
        }
    }
}

// Profile Info Previews
struct ProfileInfo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NameEntryView()
                .previewDisplayName("1. Name")
            
            LocationView(currentStep: .constant(0))
                .previewDisplayName("2. Location")
            
            GenderView()
                .previewDisplayName("3. Gender")
            
            HometownView()
                .previewDisplayName("4. Hometown")
            
            SchoolView()
                .previewDisplayName("5. School")
            
            DrinkPreferenceView()
                .previewDisplayName("6. Drinks")
            
            SmokingPreferenceView()
                .previewDisplayName("7. Smoking")
        }
    }
}

// Photo Flow Previews
struct PhotoFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhotoPromptView()
                .previewDisplayName("Photo Prompt")
            
            PhotoUploadView()
                .previewDisplayName("Photo Upload")
        }
    }
}

// Add these placeholder views after ActionButton
struct MessagesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")  // Dark blue background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Connections")
                        .font(.system(size: 45, weight: .bold))  // Larger font
                        .foregroundColor(.white)  // Changed to white for contrast
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {  // Increased spacing
                            // Groups Section
                            VStack(alignment: .leading, spacing: 20) {  // Increased spacing
                                Text("Groups")
                                    .font(.system(size: 30))  // Larger font
                                    .foregroundColor(.white)
                                    .bold()
                                
                                // Group Cards
                                GroupChatCard(
                                    groupName: "Golden Girls 💕",
                                    message: "This app is insane",
                                    memberImages: ["guy1", "guy2", "guy3"]
                                )
                                
                                GroupChatCard(
                                    groupName: "Alcoholics",
                                    message: "How many features are on...",
                                    memberImages: ["guy1", "guy2", "guy3"]
                                )
                            }
                            .padding(.horizontal)
                            
                            // Direct Messages
                            VStack(spacing: 20) {  // Increased spacing
                                ForEach(["Bailey", "Ashley", "Johnny", "Sam"], id: \.self) { name in
                                    DirectMessageRow(
                                        name: name,
                                        message: name == "Bailey" ? "just sent you a drink :)" :
                                                name == "Ashley" ? "We r going to Shoreclub!" :
                                                name == "Johnny" ? "You go to UCSD?" : "u going out tn",
                                        location: name == "Bailey" ? "Shoreclub" :
                                                 name == "Ashley" ? "Hideaway" :
                                                 name == "Sam" ? "Hideaway" : nil
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                }
            }
        }
    }
}

struct GroupChatCard: View {
    let groupName: String
    let message: String
    let memberImages: [String]
    
    var body: some View {
        HStack(spacing: 20) {  // Increased spacing
            // Group member images
            ZStack {
                ForEach(memberImages.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)  // Larger circles
                        .offset(x: CGFloat(index * 25))  // Adjusted offset
                }
            }
            .frame(width: 100, alignment: .leading)  // Wider frame
            
            VStack(alignment: .leading, spacing: 8) {  // Increased spacing
                Text(groupName)
                    .font(.system(size: 20, weight: .bold))  // Larger font
                    .foregroundColor(Color("DarkPurple"))
                
                Text(message)
                    .font(.system(size: 16))  // Larger font
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)  // More vertical padding
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct DirectMessageRow: View {
    let name: String
    let message: String
    let location: String?
    
    var body: some View {
        HStack(spacing: 20) {  // Increased spacing
            // Profile image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)  // Larger circle
            
            VStack(alignment: .leading, spacing: 8) {  // Increased spacing
                HStack {
                    Text(name)
                        .font(.system(size: 20, weight: .bold))  // Larger font
                        .foregroundColor(Color("DarkPurple"))
                    
                    if let location = location {
                        Text("@ \(location)")
                            .font(.system(size: 16))  // Larger font
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("Salmon").opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                
                Text(message)
                    .font(.system(size: 16))  // Larger font
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)  // More vertical padding
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct MapView: View {
    var body: some View {
        Text("Map Coming Soon")
            .font(.largeTitle)
    }
}

struct GroupsView: View {
    var body: some View {
        Text("Groups Coming Soon")
            .font(.largeTitle)
    }
}

struct ProfileView: View {
    @State private var showingEditProfile = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header with Circle Image
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                    
                    // Name and Verification
                    HStack(spacing: 8) {
                        Text("Ashley")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("NeonPink"))
                            .font(.system(size: 24))
                    }
                    
                    // Custom Segmented Control
                    HStack(spacing: 0) {
                        TabButton(text: "Photos", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        
                        TabButton(text: "Info", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        // Photos Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(0..<6) { index in
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(10)
                                    
                                    // Edit Button for each photo
                                    Button(action: {
                                        // Add photo edit action here
                                    }) {
                                        Circle()
                                            .fill(Color("Salmon"))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Info View
                        VStack(alignment: .leading, spacing: 20) {
                            InfoSection(title: "Basic Info", items: [
                                InfoItem(icon: "person.fill", text: "Woman"),
                                InfoItem(icon: "calendar", text: "23 years old"),
                                InfoItem(icon: "mappin.circle.fill", text: "San Diego, CA"),
                                InfoItem(icon: "house.fill", text: "From: Chicago, IL")
                            ])
                            
                            InfoSection(title: "Work & Education", items: [
                                InfoItem(icon: "briefcase.fill", text: "Software Engineer @ Apple"),
                                InfoItem(icon: "graduationcap.fill", text: "SDSU - Computer Science")
                            ])
                            
                            InfoSection(title: "Preferences", items: [
                                InfoItem(icon: "person.2.fill", text: "Show me: Everyone"),
                                InfoItem(icon: "wineglass.fill", text: "Favorite drink: Tequila Sunrise")
                            ])
                            
                            Text("BarBuddy is for making friends! We recommend seeing both guys and girls in your area to maximize your social circle.")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 5)
                        }
                        .padding(.top)
                    }
                }
            }
            .background(Color("DarkBlue"))
        }
    }
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 120, height: 40)
                .background(isSelected ? Color("Salmon") : Color.clear)
                .cornerRadius(25)
        }
    }
}

struct InfoSection: View {
    let title: String
    let items: [InfoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(items) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(Color("Salmon"))
                    Text(item.text)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InfoItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

// Add this new preview provider
struct HomeFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDisplayName("Home Tab Bar")
            
            MainFeedView(selectedTab: .constant(2))
                .previewDisplayName("Main Feed")
            
            BarCard(selectedTab: .constant(0))
                .previewDisplayName("Bar Card")
                .padding()
        }
    }
}

struct CrowdLevelGraph: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Crowds")
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
            
            Text("Hideaway is crowded right now")
                .font(.subheadline)
                .foregroundColor(Color("DarkPurple"))
            
            // Curved Graph
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height * 0.8
                    
                    // Create curve points
                    let points: [CGPoint] = [
                        .init(x: 0, y: height * 0.7),
                        .init(x: width * 0.2, y: height * 0.6),
                        .init(x: width * 0.4, y: height * 0.3),
                        .init(x: width * 0.6, y: height * 0.2),
                        .init(x: width * 0.8, y: height * 0.1),
                        .init(x: width, y: height * 0.4)
                    ]
                    
                    // Draw the curve
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: points[0])
                    
                    for index in 0..<points.count-1 {
                        let control1 = CGPoint(x: points[index].x + (points[index+1].x - points[index].x) / 2,
                                             y: points[index].y)
                        let control2 = CGPoint(x: points[index].x + (points[index+1].x - points[index].x) / 2,
                                             y: points[index+1].y)
                        
                        path.addCurve(to: points[index+1],
                                    control1: control1,
                                    control2: control2)
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color("DarkPurple").opacity(0.3),
                        Color("DarkPurple").opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                
                // Add the line on top
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height * 0.8
                    
                    let points: [CGPoint] = [
                        .init(x: 0, y: height * 0.7),
                        .init(x: width * 0.2, y: height * 0.6),
                        .init(x: width * 0.4, y: height * 0.3),
                        .init(x: width * 0.6, y: height * 0.2),
                        .init(x: width * 0.8, y: height * 0.1),
                        .init(x: width, y: height * 0.4)
                    ]
                    
                    path.move(to: points[0])
                    
                    for index in 0..<points.count-1 {
                        let control1 = CGPoint(x: points[index].x + (points[index+1].x - points[index].x) / 2,
                                             y: points[index].y)
                        let control2 = CGPoint(x: points[index].x + (points[index+1].x - points[index].x) / 2,
                                             y: points[index+1].y)
                        
                        path.addCurve(to: points[index+1],
                                    control1: control1,
                                    control2: control2)
                    }
                }
                .stroke(Color("DarkPurple"), lineWidth: 2)
                
                // Add vertical indicator line at current time (around 9pm position)
                Path { path in
                    let height = geometry.size.height * 0.8
                    path.move(to: CGPoint(x: geometry.size.width * 0.65, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.65, y: height))
                }
                .stroke(Color("Salmon"), lineWidth: 1)
                .opacity(0.8)
                
                // Add indicator dot
                Circle()
                    .fill(Color("Salmon"))
                    .frame(width: 8, height: 8)
                    .position(x: geometry.size.width * 0.65, 
                            y: geometry.size.height * 0.8 * 0.15)  // Position on the curve
                
                // Time labels with more marks
                HStack {
                    Text("12pm")
                    Spacer()
                    Text("3pm")
                    Spacer()
                    Text("6pm")
                    Spacer()
                    Text("9pm")
                    Spacer()
                    Text("12am")
                    Spacer()
                    Text("3am")
                    Spacer()
                    Text("6am")
                }
                .foregroundColor(Color("DarkPurple"))
                .font(.system(size: 8))
                .offset(y: geometry.size.height * 0.85)
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

// Update BarDetailPopup to replace the posting section with the graph
struct BarDetailPopup: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with bar name and hours
                    VStack(spacing: 8) {
                        Text("Hideaway")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        
                        HStack {
                            Text("Open")
                                .foregroundColor(.red)
                            Text("11am - 2am")
                                .foregroundColor(Color("DarkPurple"))
                        }
                    }
                    
                    // Friends avatars section
                    VStack(spacing: 10) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { _ in
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("+6 of your friends are here!")
                            .foregroundColor(Color("DarkPurple"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    // Quick info tags
                    HStack(spacing: 15) {
                        InfoBubble(icon: "music.note", text: "House")
                        InfoBubble(icon: "flame.fill", text: "Packed")
                        InfoBubble(text: "$ 5 - 20")
                    }
                    
                    // Wait time and crowd size
                    HStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text("Est. Wait Time:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            
                            Text("20 - 30 min")
                                .padding()
                                .background(Color("Salmon").opacity(0.2))
                                .cornerRadius(15)
                            
                            Text("Vote wait time!")
                                .bold()
                                .underline()
                                .foregroundColor(Color("DarkPurple"))
                        }
                        
                        VStack(spacing: 10) {
                            Text("Crowd Size is:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color("DarkPurple"))
                                Text("Packed")
                            }
                            .padding()
                            .background(Color("Salmon").opacity(0.2))
                            .foregroundColor(Color("DarkPurple"))
                            .cornerRadius(15)
                            
                            Text("Vote crowd size!")
                                .bold()
                                .underline()
                                .foregroundColor(Color("DarkPurple"))
                        }
                    }
                    
                    // Replace image and post button with crowd level graph
                    CrowdLevelGraph()
                    
                    // Single action button for Swipe
                    Button(action: {}) {
                        HStack {
                            Text("Swipe")
                            Image(systemName: "person.2.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Helper for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct InfoBubble: View {
    var icon: String?
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color("Salmon").opacity(0.2))
        .foregroundColor(Color("DarkPurple"))
        .cornerRadius(20)
    }
}

// Update the preview
struct BarDetailPopup_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .overlay {
                BarDetailPopup(isPresented: .constant(true))
            }
            .previewDisplayName("Bar Detail Popup")
    }
}

// Update WaitTimeVotingView
struct WaitTimeVotingView: View {
    @Binding var isPresented: Bool
    @State private var selectedTime: String?
    
    let waitTimeOptions = [
        "<5min",
        "5 - 10 min",
        "10 - 20 min",
        "20 - 30 min",
        "30 - 45 min",
        ">45 min"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(waitTimeOptions, id: \.self) { time in
                Button(action: {
                    selectedTime = time
                    isPresented = false
                }) {
                    Text(time)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(width: 200)  // Fixed width for the popup
    }
}

// Add this preference key to track scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
