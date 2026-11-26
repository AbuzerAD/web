import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let workouts: WorkoutService
    let exercises: ExerciseLibraryService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PTTheme.Spacing.lg) {
                PTCard {
                    VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                        Text(workout.name).font(PTTheme.Typography.title)
                        Text(workout.summary).font(PTTheme.Typography.body).foregroundStyle(PTTheme.Colors.textSecondary)
                        HStack {
                            PTPill("\(workout.estimatedMinutes) min")
                            PTPill(workout.difficulty.rawValue.capitalized, color: PTTheme.Colors.accent)
                            PTPill("\(workout.totalExercises) exercises")
                        }
                    }
                }
                .padding(.horizontal)

                ForEach(workout.blocks) { block in
                    VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                        PTSectionHeader(block.title, subtitle: "\(block.exercises.count) exercises")
                            .padding(.horizontal)
                        ForEach(block.exercises.sorted { $0.order < $1.order }) { we in
                            PTCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(we.exerciseName).font(PTTheme.Typography.headline)
                                        Text("\(we.sets) × \(we.reps) · rest \(we.restSec)s")
                                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                        if let t = we.tempo { Text("Tempo \(t)").font(PTTheme.Typography.caption) }
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(PTTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
