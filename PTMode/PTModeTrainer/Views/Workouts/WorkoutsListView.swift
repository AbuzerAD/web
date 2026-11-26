import SwiftUI

struct WorkoutsListView: View {
    let workouts: WorkoutService
    let exercises: ExerciseLibraryService
    @State private var showBuilder = false
    @State private var editing: Workout?

    var body: some View {
        NavigationStack {
            Group {
                if workouts.workouts.isEmpty {
                    PTEmptyState(icon: "dumbbell", title: "No workouts yet",
                                 message: "Create your first custom workout.")
                } else {
                    List {
                        ForEach(workouts.workouts) { w in
                            NavigationLink {
                                WorkoutDetailView(workout: w, workouts: workouts, exercises: exercises)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(w.name).font(PTTheme.Typography.headline)
                                    Text("\(w.totalExercises) exercises · \(w.estimatedMinutes) min · \(w.difficulty.rawValue.capitalized)")
                                        .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                }
                            }
                        }
                        .onDelete { idx in
                            for i in idx { Task { await workouts.delete(id: workouts.workouts[i].id) } }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showBuilder = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showBuilder) {
                WorkoutBuilderView(workouts: workouts, exercises: exercises, existing: nil)
            }
            .task { await workouts.load(trainerID: UUID()) }
        }
    }
}
