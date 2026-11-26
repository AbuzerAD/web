import SwiftUI

struct ClientDetailView: View {
    let client: User
    let clients: ClientService
    let workouts: WorkoutService

    @State private var showAssign = false

    var body: some View {
        ScrollView {
            VStack(spacing: PTTheme.Spacing.lg) {
                PTCard {
                    VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                        Text(client.fullName).font(PTTheme.Typography.title)
                        Text(client.email).font(PTTheme.Typography.subheadline).foregroundStyle(PTTheme.Colors.textSecondary)
                        if let p = clients.profile(for: client.id) {
                            HStack(spacing: PTTheme.Spacing.sm) {
                                PTPill(p.fitnessLevel.rawValue.capitalized, color: PTTheme.Colors.accent)
                                ForEach(p.goals.prefix(3), id: \.self) { PTPill($0) }
                            }
                            if !p.injuries.isEmpty {
                                Text("Injuries: " + p.injuries.joined(separator: ", "))
                                    .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.danger)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                PTSectionHeader("Assigned workouts", subtitle: "Tap to assign a new one")
                    .padding(.horizontal)

                if workouts.workouts.isEmpty {
                    PTEmptyState(icon: "dumbbell", title: "No workouts", message: "Create a workout first.")
                        .padding(.horizontal)
                } else {
                    VStack(spacing: PTTheme.Spacing.sm) {
                        ForEach(workouts.workouts) { w in
                            PTCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(w.name).font(PTTheme.Typography.headline)
                                        Text("\(w.totalExercises) exercises · \(w.estimatedMinutes) min")
                                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Button("Assign") {
                                        Task {
                                            let s = ScheduledWorkout(
                                                clientID: client.id,
                                                trainerID: w.trainerID,
                                                workoutID: w.id,
                                                workoutName: w.name,
                                                scheduledDate: .now
                                            )
                                            await workouts.assign(s)
                                        }
                                    }
                                    .font(PTTheme.Typography.subheadline)
                                    .foregroundStyle(PTTheme.Colors.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(PTTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(client.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await workouts.load(trainerID: UUID()) }
    }
}
