//
//  CountdownView.swift
//  LISDSurvey
//
//  Created by Sai venkat Veerapaneni on 6/12/25.
//

import SwiftUI

struct CountdownView: View {
    let endTime: Date
    let onExpire: () -> Void

    @State private var timeLeft: TimeInterval = 0
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if timeLeft > 0 {
                Text("Closes in: \(formattedTimeLeft())")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(12)
            }
        }
        .onAppear {
            updateTimeLeft()
        }
        .onReceive(timer) { _ in
            updateTimeLeft()
        }
    }

    private func updateTimeLeft() {
        let newTimeLeft = endTime.timeIntervalSinceNow
        if newTimeLeft <= 0 {
            timeLeft = 0
            onExpire()
        } else {
            timeLeft = newTimeLeft
        }
    }

    private func formattedTimeLeft() -> String {
        let totalMinutes = Int(timeLeft / 60)
        let days = totalMinutes / 1440
        let hours = (totalMinutes % 1440) / 60
        let minutes = totalMinutes % 60

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
