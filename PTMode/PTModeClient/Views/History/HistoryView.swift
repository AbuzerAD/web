import SwiftUI

struct HistoryView: View {
    let sessions: SessionService

    var body: some View {
        NavigationStack {
            Group {
                if sessions.sessions.isEmpty {
                    PTEmptyState(icon: "clock", title: "No history yet",
                                 message: "Completed workouts will appear here.")
                } else {
                    List(sessions.sessions.sorted { $0.startedAt > $1.startedAt }) { s in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.workoutName).font(PTTheme.Typography.headline)
                            HStack {
                                Text(s.startedAt.formatted(date: .abbreviated, time: .shortened))
                                if let d = s.durationMinutes { Text("· \(d) min") }
                                if let rpe = s.perceivedExertion { Text("· RPE \(rpe)") }
                            }
                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .task { /* sessions loaded by parent */ }
        }
    }
}
