//
//  CrowdLevelGraph.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

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
