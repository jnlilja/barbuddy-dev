//
//  SettingsView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(BarViewModel.self) var barViewModel
    @State private var showApperanceSettings = false
    @State private var selectedTheme: String?

    var body: some View {
        List {
            Section(header: Text("Account").foregroundStyle(.nude)) {
                Button {
                    
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Button {
                    
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text("Change Password")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Button {
                    URLCache.shared.removeAllCachedResponses()
                    UserDefaults.standard.removeObject(forKey: "barStatuses_cache_timestamp")
                    UserDefaults.standard.removeObject(forKey: "barHours_cache_timestamp")
                    barViewModel.stopStatusRefreshTimer()
                    viewModel.signOut()
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "figure.walk.departure")
                            .frame(width: 24, height: 24)
                        if viewModel.authUser?.isAnonymous ?? true {
                            Text("Return to Menu")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("Logout")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                if let isAnonymous = viewModel.authUser?.isAnonymous, !isAnonymous {
                    NavigationLink(destination: ConfirmDeleteView()) {
                        HStack(spacing: 15) {
                            Image(systemName: "trash.fill")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.red)
                            Text("Delete Account")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .tint(.primary)
            
            Section(header: Text("More").foregroundStyle(.nude)) {
                Button {
                    
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "info.circle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text("About Us")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Button {
                    
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "checkmark.shield")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text("Terms of Service")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Button {
                    showApperanceSettings = true
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: "moon.stars.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text("Apperance")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .tint(.primary)
        }
        .scrollContentBackground(.hidden)
        .background(colorScheme == .dark ? Color(.secondarySystemFill) : .darkBlue.opacity(0.9))
        .toolbarBackground(.darkBlue, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Settings")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
            }
        }
        .sheet(isPresented: $showApperanceSettings) {
            AppearanceSettingView()
                .presentationDetents([.fraction(0.2)])
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
            .environment(BarViewModel())
    }
}
