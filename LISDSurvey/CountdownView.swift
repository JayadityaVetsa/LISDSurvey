// CountdownView.swift – fixed ViewBuilder error by moving side‑effect into .onAppear
// LISDSurvey

import SwiftUI

/// A lightweight, precise countdown badge that refreshes once per minute **and**
/// delivers the first update immediately on appearance.
struct CountdownView: View {
    let endTime: Date
    let onExpire: () -> Void

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            let remaining = endTime.timeIntervalSince(context.date)

            if remaining <= 0 {
                // Return a View and perform side‑effect safely inside .onAppear
                EmptyView()
                    .onAppear {
                        onExpire()
                    }
            } else {
                Text("Closes in: \(formattedRemaining(remaining))")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(12)
            }
        }
    }

    // MARK: – Helpers
    private func formattedRemaining(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval / 60)
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
