//
//  CoolDownView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/12/25.
//

import SwiftUI
import Observation

struct TimerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var timer: TimerManager
    
    var body: some View {
        // Total length is fixed (5 minutes) so we can hard-code it here
        let totalDuration: TimeInterval = 5 * 60

        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let remaining = timer.timeRemaining
            let progress  = remaining / totalDuration
            
            ZStack {
                // background circle
                Circle()
                    .stroke(colorScheme == .dark ? .nude.opacity(0.3) : .darkPurple.opacity(0.3), lineWidth: 20)
                
                // progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(colorScheme == .dark ? .nude : .darkBlue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                // timer text in MM:SS
                Text(timeString(from: remaining))
                    .font(.title)
                    .contentTransition(.numericText())
                    .monospacedDigit()
                    .bold()
            }
            .animation(.linear(duration: 1), value: progress)
            .frame(width: 120, height: 120)
            .onChange(of: remaining) { _, _ in
                if !timer.isActive {
                    timer.reset()
                }
            }
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TimerView(timer: TimerManager(id: 1))
        .environment(TimerManager(id: 1))
        .padding(20)
}
