import SwiftUI

struct HomeView: View {
    let auth: AuthService
    let workouts: WorkoutService
    let sessions: SessionService
    @State private var scheduled: [ScheduledWorkout] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PTTheme.Spacing.lg) {
                    PTCard {
                        VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                            Text("Hi, \(auth.currentUser?.fullName.split(separator: " ").first ?? "there") 👋")
                                .font(PTTheme.Typography.title)
                            Text("Ready to train today?").font(PTTheme.Typography.subheadline)
                                .foregroundStyle(PTTheme.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal)

                    PTSectionHeader("Today's workout").padding(.horizontal)

                    if scheduled.isEmpty {
                        PTEmptyState(icon: "calendar", title: "No workout scheduled",
                                     message: "Your trainer will assign your next session.")
                            .padding(.horizontal)
                    } else {
                        ForEach(scheduled) { s in
                            NavigationLink {
                                WorkoutPlayerView(scheduled: s, workouts: workouts, sessions: sessions,
                                                  clientID: auth.currentUser?.id ?? UUID())
                            } label: {
                                PTCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(s.workoutName).font(PTTheme.Typography.headline)
                                            Text(s.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "play.circle.fill")
                                            .font(.title).foregroundStyle(PTTheme.Colors.primary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }

                    PTSectionHeader("Recent sessions").padding(.horizontal)
                    if sessions.sessions.isEmpty {
                        PTEmptyState(icon: "clock", title: "No sessions yet",
                                     message: "Complete a workout to see history.")
                            .padding(.horizontal)
                    } else {
                        ForEach(sessions.sessions.prefix(3)) { sess in
                            PTCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(sess.workoutName).font(PTTheme.Typography.headline)
                                        Text(sess.startedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                    }
                                    Spacer()
                                    if let d = sess.durationMinutes { Text("\(d) min").font(PTTheme.Typography.subheadline) }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(PTTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Home")
            .task {
                await workouts.load(trainerID: UUID())
                await sessions.load(clientID: auth.currentUser?.id ?? UUID())
                // mock scheduled
                if let w = workouts.workouts.first {
                    scheduled = [ScheduledWorkout(clientID: auth.currentUser?.id ?? UUID(),
                                                 trainerID: w.trainerID, workoutID: w.id,
                                                 workoutName: w.name, scheduledDate: .now)]
                }
            }
        }
    }
}
