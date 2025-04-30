//
//  UsersViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?

    init() { Task { await loadUsers() } }

    func loadUsers() async {
        do { users = try await GetUserAPIService.shared.fetchAll() }
        catch { users = []; errorMessage = error.localizedDescription }
    }
}
