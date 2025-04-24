import SwiftUI

struct TestAPIView: View {
    @State private var users: [GetUser] = []
    @State private var error: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                List(users) { user in
                    VStack(alignment: .leading) {
                        Text(user.fullName)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                        if let picture = user.mainProfilePicture {
                            AsyncImage(url: URL(string: picture)) { image in
                                image.resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 100)
                        }
                    }
                }
            }
            
            Button("Test API") {
                testAPI()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func testAPI() {
        isLoading = true
        error = nil
        
        Task {
            do {
                users = try await GetUserAPIService.shared.fetchUsers()
            } catch let apiError as APIError {
                error = apiError.errorDescription
            } catch {
                error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    TestAPIView()
} 