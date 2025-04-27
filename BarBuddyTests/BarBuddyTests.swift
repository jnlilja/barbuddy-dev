//
//  BarBuddyTests.swift
//  BarBuddyTests
//
//  Created by Jessica Lilja on 2/5/25.
//  Commit and push test

import Testing
@testable import BarBuddy

@Suite("Password Validation")
struct PasswordValidationTest {
    
    @MainActor
    @Test func testSuccessfulPasswordValidation() async throws {
        let user = SignUpViewModel()
        user.email = "test@test.com"
        user.newUsername = "testUser"
        user.newPassword = "Testing123!"
        user.validateAndSignUp()
        #expect(user.alertMessage != "Password must be ≥ 8 characters with a number & special char.")
    }
    
    @MainActor
    @Test func testFailedPasswordValidation() async throws {
        let user = SignUpViewModel()
        user.email = "test@test.com"
        user.newUsername = "testUser"
        user.newPassword = "Testing"
        user.validateAndSignUp()
        #expect(user.alertMessage == "Password must be ≥ 8 characters with a number & special char.")
    }
}

@Suite("Email Validation")
struct EmailValidaionTest {

    @MainActor
    @Test func testSuccessfulEmailValidation() async throws {
        let user = SignUpViewModel()
        user.email = "test@test.com"
        user.newUsername = "testUser"
        user.newPassword = "Testing123!"
        user.validateAndSignUp()
        #expect(user.alertMessage != "Please enter a valid email.")
    }
    
    @MainActor
    @Test func testFailedEmailValidation() async throws {
        let user = SignUpViewModel()
        user.email = "test"
        user.newUsername = "testUser"
        user.newPassword = "Testing123!"
        user.validateAndSignUp()
        #expect(user.alertMessage == "Please enter a valid email.")
    }
}
