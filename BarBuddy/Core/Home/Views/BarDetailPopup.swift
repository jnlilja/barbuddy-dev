import MapKit
import SDWebImageSwiftUI
//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import FirebaseAuth

struct BarVote: Codable {
    let bar: Int
    let wait_time: String
}

struct PostBarVote: Codable {
    let bar: Int
    let wait_time: String
}

class BarDetailPopupViewModel: ObservableObject {
    
    func getBarVotes() async throws -> [BarVote] {
        guard let uid = Auth.auth().currentUser else { throw UsersAPIError.noToken }
        let idToken = try await uid.getIDToken()
        //var request = URLRequest(url: baseURL.appendingPathComponent("users"))
        guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/bar-votes/") else {
            return []
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonData = String(data: data, encoding: .utf8) {
                print("suggestions json \(jsonData)")
            }
            return try JSONDecoder().decode([BarVote].self, from: data)
        } catch let e as DecodingError {
            throw UsersAPIError.decoding(e)
        } catch {
            throw UsersAPIError.transport(error)
        }
    }
    
    func createBarVote(bar: Bar, waitTime: String) async -> Bool {
        
        guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/bar-votes/") else {
            return false
        }
        
        let barVoteBody = PostBarVote(bar: bar.id, wait_time: waitTime)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(barVoteBody)
        }
        catch {
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("json string: \(jsonString)")
            }
            
            if let responseStatusCode = response as? HTTPURLResponse {
                if responseStatusCode.statusCode >= 400 {
                    print("bad response \(responseStatusCode.statusCode)")
                    return false
                }
                if responseStatusCode.statusCode == 200 || responseStatusCode.statusCode == 201 {
                    return true
                }
            }
            
        } catch {
            return false
        }
        
        return false
    }
    
}

struct BarDetailPopup: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MapViewModel
    @StateObject var barDetailViewModel = BarDetailPopupViewModel()
    let bar: Bar
    @State private var waitButtonProperties = ButtonProperties(type: "wait")
    @State private var crowdButtonProperties = ButtonProperties(type: "crowd")
    // Helper to find this bar’s index in the viewModel
    private var idx: Int {
        viewModel.bars.firstIndex { $0.id == bar.id } ?? -1
    }
    // Dynamic values from your endpoints
    private var musicType: String {
        viewModel.music[idx] ?? "–"
    }
    private var crowdSize: String {
        viewModel.statuses[idx]?.crowd_size ?? "–"
    }
    private var priceRange: String {
        viewModel.pricing[idx] ?? "–"
    }
    private var waitTime: String {
        viewModel.statuses[idx]?.wait_time ?? "–"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // MARK: — Header
                VStack(spacing: 8) {
                    Text(bar.name)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("DarkPurple"))
                    HStack {
                        Text("Open")
                            .foregroundColor(.red)
                        Text("11am – 2am")
                            .foregroundColor(Color("DarkPurple"))
                    }
                }
                // MARK: — Quick‑info bubbles (music, crowd, price)
                HStack(spacing: 15) {
                    InfoBubble(icon: "music.note", text: musicType)
                    InfoBubble(icon: "flame.fill", text: crowdSize)
                    InfoBubble(icon: "dollarsign.circle", text: priceRange)
                }
                // MARK: — Wait time & crowd voting
                HStack(spacing: 30) {
                    // Wait‑time section
                    VStack(spacing: 10) {
                        if !waitButtonProperties.selectedOption {
                            Text("Est. Wait Time:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.salmon.opacity(0.2))
                                    .frame(width: 131, height: 50)
                                Text(bar.waitTime ?? "-")
                                    .foregroundColor(Color("DarkPurple"))
                                    .bold()
                            }

                            Button {
                                // send vote with current values
//                                Task {
//                                    let result = await BarStatusService.shared.createBarVote(bar: bar, waitTime: waitTime)
//                                    if result {
//                                        print("vote worked!")
//                                    } else {
//                                        print("vote failed!")
//                                    }
////                                    try? await BarStatusService.shared
////                                        .submitVote(
////                                            barId: idx,
////                                            crowdSize: crowdSize,
////                                            waitTime: waitTime
////                                        )
////                                    await viewModel.loadBarData()
//                                }
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    waitButtonProperties.showMenu = true
                                    crowdButtonProperties.showMenu = false
                                }

                            } label: {
                                Text("Vote wait time!")
                                    .bold()
                                    .underline()
                                    .foregroundColor(Color("DarkPurple"))
                            }
                            .disabled(waitButtonProperties.showMenu)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(
                                        Gradient(colors: [
                                            .neonPink, .darkBlue,
                                        ]).opacity(0.7)
                                    )
                                    .frame(width: 131, height: 110)

                                Text("Voted! 👍")
                                    .foregroundStyle(.darkBlue)
                                    .padding()
                                    .cornerRadius(15)
                                    .bold()
                            }
                            .transition(.scale)
                        }
                    }
                    // Crowd‑size section
                    if !crowdButtonProperties.selectedOption {
                        VStack(spacing: 10) {

                            Text("Crowd Size is:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.salmon.opacity(0.2))
                                    .frame(width: 131, height: 50)
                                HStack {
                                    Image(systemName: "flame.fill")
                                    Text(crowdSize)
                                }
                                .foregroundColor(Color("DarkPurple"))
                                .bold()
                            }
                            Button {
                                // send vote with current values
                                Task {
                                    try? await BarStatusService.shared
                                        .submitVote(
                                            barId: idx,
                                            crowdSize: crowdSize,
                                            waitTime: waitTime
                                        )
                                    await viewModel.loadBarData()
                                }
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    crowdButtonProperties.showMenu = true
                                    waitButtonProperties.showMenu = false
                                }
                            } label: {
                                Text("Vote crowd size!")
                                    .bold()
                                    .underline()
                                    .foregroundColor(Color("DarkPurple"))
                            }
                            .disabled(crowdButtonProperties.showMenu)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(
                                    Gradient(colors: [.neonPink, .darkBlue])
                                        .opacity(0.7)
                                )
                                .frame(width: 131, height: 110)

                            Text("Voted! 👍")
                                .foregroundStyle(.darkBlue)
                                .padding()
                                .cornerRadius(15)
                                .bold()
                        }
                        .transition(.scale)
                    }
                }
                WebImage(
                    url: URL(
                        string:
                            "https://media.istockphoto.com/id/1040303026/photo/draught-beer-in-glasses.jpg?s=612x612&w=0&k=20&c=MvDv_YtiG4l1bh9vNJv5Hyb-l8ZSCsMDbxutWnCh-78="
                    )
                )
                .resizable()
                .frame(width: 350, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // MARK: — Swipe Navigation
                NavigationLink(destination: SwipeView()) {
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
            .navigationBarTitleDisplayMode(.inline)
        }
        //        .presentationDetents([.large])
        //        .presentationDragIndicator(.visible)
        // MARK: — Remove old “Feedback” view; overlay existing vote menus
        .overlay {
            // Wait‑time menu
            if waitButtonProperties.showMenu {
                HStack {
                    VoteWaitTimeView(bar: bar, properties: $waitButtonProperties)
                        .offset(x: waitButtonProperties.offset)
                        .padding(.leading)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            )
                            .onChanged { value in
                                if value.translation.width <= 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        waitButtonProperties.offset =
                                            value.translation.width
                                    }
                                }
                            }
                            .onEnded { _ in
                                if waitButtonProperties.offset < -100 {
                                    withAnimation(.snappy) {
                                        waitButtonProperties.showMenu = false
                                    }
                                }
                                withAnimation {
                                    waitButtonProperties.offset = 0
                                }
                            }
                        )
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
            // Crowd‑size menu
            if crowdButtonProperties.showMenu {
                HStack {
                    Spacer()
                    VoteCrowdSizeView(buttonProperties: $crowdButtonProperties)
                        .offset(x: crowdButtonProperties.offset)
                        .padding(.trailing)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            )
                            .onChanged { value in
                                if value.translation.width > 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        crowdButtonProperties.offset =
                                            value.translation.width
                                    }
                                }
                            }
                            .onEnded { _ in
                                if crowdButtonProperties.offset > 100 {
                                    withAnimation(.snappy) {
                                        crowdButtonProperties.showMenu = false
                                    }
                                }
                                withAnimation {
                                    crowdButtonProperties.offset = 0
                                }
                            }
                        )
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}
//struct BarDetailPopup_Previews: PreviewProvider {
//    static var previews: some View {
//        BarDetailPopup(
//            bar: Bar(
//                name: "Hideaway",
//                location: CLLocationCoordinate2D(
//                    latitude: 32.7961859,
//                    longitude: -117.2558475
//                )
//            )
//        )
//        .environmentObject(MapViewModel())
//        .previewLayout(.sizeThatFits)
//    }
//}
