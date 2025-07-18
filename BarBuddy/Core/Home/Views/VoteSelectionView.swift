//
//  VoteBoxView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/21/25.
//

import SwiftUI

struct VoteSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(BarViewModel.self) var barViewModel
    @Bindable var timer: TimerManager
    @Binding var actions: VoteButtonState
    @State private var selectedOption: String?
    @State private var submissionError: Bool = false
    @State private var error: Error?
    @State private var loadingState: LoadingState = .idle
    let bar: Bar
    
    private enum LoadingState {
        case idle, onSubmit, loading
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("How long is the wait?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .salmon : .darkBlue)
                .padding(.top)
            
            Text("Select a time below")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white :.darkPurple)
                .padding(.bottom, 20)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 70, maximum: 120), spacing: 15),
                GridItem(.adaptive(minimum: 70, maximum: 120), spacing: 15),
                GridItem(.adaptive(minimum: 70, maximum: 120))
            ]) {
                
                VoteButtonView(text: "< 5 min", opacity: 0.15, properties: $actions, selectedOption: $selectedOption)
                VoteButtonView(text: "5 - 10 min", opacity: 0.2, properties: $actions, selectedOption: $selectedOption)
                VoteButtonView(text: "10 - 20 min", opacity: 0.3, properties: $actions, selectedOption: $selectedOption)
                VoteButtonView(text: "20 - 30 min", opacity: 0.4, properties: $actions, selectedOption: $selectedOption)
                VoteButtonView(text: "> 30 min", opacity: 0.5, properties: $actions, selectedOption: $selectedOption)
            }
            .padding(.horizontal)
            .disabled(loadingState == .loading || loadingState == .onSubmit)
            
            Spacer()
            
            HStack {
                Button {
                    withAnimation {
                        actions.showMenu = false
                    }
                } label: {
                    HStack {
                        Text("Cancel")
                            .foregroundColor(Color("DarkPurple"))
                        Image(systemName: "xmark")
                            .foregroundColor(Color("DarkPurple"))
                    }
                    .frame(width: 100)
                    .padding()
                    .background(colorScheme == .dark
                                ? .nude : .salmon.opacity(0.2))
                    .foregroundColor(Color("DarkPurple"))
                    .cornerRadius(15)
                    .padding(.bottom, 30)
                }
                
                if selectedOption != nil {
                    Button {
                        loadingState = .onSubmit
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                loadingState = .loading
                            }
                        }
                        guard let vote = selectedOption else { return }
                        // remove spaces
                        let formatted = vote.replacingOccurrences(of: "> ", with: ">")
                            .replacingOccurrences(of: "< ", with: "<")
                            .replacingOccurrences(of: " - ", with: "-")
                        
                        Task {
                            do {
                                // Submit wait time
                                try await BarNetworkManager.shared.submitVote(
                                    vote: BarVote(bar: bar.id, waitTime: formatted)
                                )
                                
                                await MainActor.run {
                                    withAnimation {
                                        actions.didSubmit = true
                                        actions.beginTimer = true
                                    }
                                }
                                
                                // 1.5 seconds delay, enusres UI changes happen on main thread
                                try await Task.sleep(nanoseconds: 1_500_000_000)
                                await MainActor.run {
                                    withAnimation {
                                        actions.didSubmit = false
                                        actions.showMenu = false
                                    }
                                }
                            } catch let voteError {
                                submissionError = true
                                error = voteError
                            }
                        }
                    } label: {
                        Text("Submit Vote")
                            .frame(width: 100)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .padding()
                            .background(
                                colorScheme == .dark
                                    ? Gradient(colors: [.darkPurple, .salmon])
                                    : Gradient(colors: [.darkBlue, .darkPurple])
                            )
                            .foregroundColor(.nude)
                            .cornerRadius(15)
                            .padding(.bottom, 30)
                    }
                    .transition(.move(edge: .trailing))
                    .padding(.leading, 10)
                    .disabled(loadingState == .loading || loadingState == .onSubmit)
                }
            }
        }
        .overlay {
            if loadingState == .loading && !submissionError {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color(.secondarySystemGroupedBackground))
                        .shadow(radius: 5)
                    
                    ProgressView()
                        .tint(.salmon)
                }
                .transition(.scale)
            }
        }
        .alert("Vote Submission Failed", isPresented: $submissionError) {
            Button("OK", role: .cancel) {
                loadingState = .idle
            }
        } message: {
            if error is APIError {
                switch error as? APIError {
                case .noToken:
                    Text("Please sign in to vote for wait times.")
                case .statusCode(let code):
                    handleStatusCodeError(code)
                default:
                    EmptyView()
                }
                
            } else if let error = error as? NSError, error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorTimedOut: Text("Connection timed out. Check your internet connection and try again.")
                case NSURLErrorNetworkConnectionLost: Text("Network connection lost. Check your internet connection and try again.")
                case NSURLErrorSecureConnectionFailed: Text("A secure connection could not be established. Check your internet connection and try again.")
                    
                default: Text("An unknown network error occurred. Check your internet connection and try again.")
                        .onAppear() {
                            print(error.localizedDescription)
                        }
                }
            } else {
                Text("An unknown error occurred.")
            }
        }
        .sensoryFeedback(.success, trigger: actions.didSubmit)
    }
}

private func handleStatusCodeError(_ code: Int) -> some View {
    switch code {
    case 400..<500: Text("The vote you submitted was invalid.")
    default: Text("Failed to submit vote. Status code: \(code)")
    }
}

#if DEBUG
#Preview {
    VoteSelectionView(
        timer: TimerManager(id: 1),
        actions: .constant(
            .init(didSubmit: false, showMenu: false, type: "wait")
        ),
        bar: Bar.sampleBar
    )
    .environment(BarViewModel.preview)
}
#endif
