import SwiftUI
import CoreLocation

struct SwipeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var vm = SwipeViewModel()
    @State private var isLikeAnimating = false
    @State private var isDislikeAnimating = false
    
    var currentUsers: [UserProfile] {
        if vm.isFiltered {
            return vm.filteredUsers
        } else {
            return vm.users
        }
    }
    
    fileprivate func SearchRow(bar: Bar) -> some View {
        HStack {
            Text(bar.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
    }
    
    private func barFilterIndicator(bar: Bar) -> some View {
        HStack(spacing: 12) {
            // Bar image
            if let firstImage = bar.images?.first, let imageURL = URL(string: firstImage.image) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "building.2")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    case .empty:
                        ProgressView()
                            .scaleEffect(0.8)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "building.2")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            
            // Bar info
            VStack(alignment: .leading, spacing: 4) {
                Text("Users near")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                Text(bar.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Close button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    vm.clearFilter()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
                    .background(Circle().fill(Color.black.opacity(0.3)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkPurple").ignoresSafeArea()
                if !vm.searchText.isEmpty {
                    if !vm.barsSearchResult.isEmpty {
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(vm.barsSearchResult) { bar in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            vm.filterUsersByBar(bar)
                                            vm.searchText = ""
                                        }
                                    } label: {
                                        SearchRow(bar: bar)
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 8)
                                    Divider()
                                }
                            }
                            .padding(.vertical, 15)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        Text("No search results")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                } else {
                    VStack {
                        // Bar filter indicator
                        if vm.isFiltered, let selectedBar = vm.selectedBar {
                            barFilterIndicator(bar: selectedBar)
                                //.padding(.top, 10)
                        }
                        
                        if !vm.isLoading {
                            ZStack {
                                if currentUsers.isEmpty {
                                    VStack(spacing: 20) {
                                        Image(systemName: "location.slash")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(vm.isFiltered ? "No users found near \(vm.selectedBar?.name ?? "")" : "No users found")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                        
                                        if vm.isFiltered {
                                            Button("Show all users") {
                                                withAnimation {
                                                    vm.clearFilter()
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(20)
                                        }
                                    }
                                } else {
                                    ForEach(currentUsers.reversed()) { profile in
                                        SwipeCard(profile: profile)
                                            .overlay(actionButtons(for: profile))
                                            .padding(.top, -20)
                                    }
                                }
                                Spacer()
                            }
                        }
                        else {
                            VStack {
                                ProgressView()
                                    .tint(.white)
                                Text("Loading...")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
            .onChange(of: vm.searchText, { _, newValue in
                guard newValue.count > 0 else { return }
                let queriedBars = vm.searchBars(query: newValue)
                vm.barsSearchResult = queriedBars
            })
            .searchable(text: $vm.searchText)
            .toolbarBackground(Color("DarkPurple"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                do {
                    vm.isLoading = true
                    let bars = try await BarNetworkManager.shared.fetchAllBars()
                    await vm.loadSuggestions()
                    vm.isLoading = false
                    if let bars = bars {
                        vm.bars = bars
                    } else {
                        print("never found bars")
                    }
                } catch {
                    print("Error fetching bars: \(error)")
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
        .accentColor(.white)
    }

    // MARK: - Like / dislike buttons overlay
    private func actionButtons(for profile: UserProfile) -> some View {
        HStack {
            // Dislike
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
                    isDislikeAnimating = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation { vm.swipeLeft(profile: profile) }
                    isDislikeAnimating = false
                }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 26))
                            .foregroundColor(.red)
                            .scaleEffect(isDislikeAnimating ? 1.3 : 1.0)
                            .rotationEffect(.degrees(isDislikeAnimating ? -15 : 0))
                    )
                    .scaleEffect(isDislikeAnimating ? 1.1 : 1.0)
            }
            .padding(.leading, 30)

            Spacer()

            // Like
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
                    isLikeAnimating = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation { vm.swipeRight(profile: profile) }
                    isLikeAnimating = false
                }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color("Salmon"))
                            .scaleEffect(isLikeAnimating ? 1.3 : 1.0)
                    )
                    .scaleEffect(isLikeAnimating ? 1.1 : 1.0)
                    .overlay(
                        ForEach(0..<(isLikeAnimating ? 6 : 0), id: \.self) { index in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color("Salmon"))
                                .offset(
                                    x: isLikeAnimating ? CGFloat.random(in: -30...30) : 0,
                                    y: isLikeAnimating ? CGFloat.random(in: (-30)...(-10)) : 0
                                )
                                .opacity(isLikeAnimating ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.5).delay(Double(index) * 0.02),
                                    value: isLikeAnimating
                                )
                        }
                    )
            }
            .padding(.trailing, 30)
        }
        .offset(y: UIScreen.main.bounds.height * 0.085)
    }
}

#Preview {
    SwipeView()
        .environmentObject(SessionManager())
}
