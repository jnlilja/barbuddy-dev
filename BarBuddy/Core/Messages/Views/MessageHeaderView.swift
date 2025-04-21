//
//  MessageHeaderView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/20/25.
//
import SwiftUI

struct MessageHeaderView: View {
    @State var location: String?
    @State var recipient: String
    
    var body: some View {
  
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2))
                    .fill(.white)
                    .frame(width: 310, height: 80)
                   
                HStack {
                    ZStack {
                        Circle()
                            .stroke()
                            .fill(Color.gray)
                            .frame(height: 70)
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.nude)
                    }
                    .padding(.leading)
                    VStack(alignment: .leading) {
                        Text(recipient)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let location = location {
                            Text("@ \(location)")
                                .font(.system(size: 16))  // Larger font
                                .foregroundColor(.white)
                                .frame(width: 120, height: 28)
                                .background(Color("Salmon").opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.leading)
    }
}

#Preview {
    MessageHeaderView(location: "Dirty Birds", recipient: "Alice")
        .background(Color.gray.opacity(0.2))
}
