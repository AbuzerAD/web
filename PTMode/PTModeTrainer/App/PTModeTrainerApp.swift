import SwiftUI
import SwiftData

@main
struct PTModeTrainerApp: App {
    @State private var backend = MockBackendService()
    @State private var auth: AuthService
    @State private var clients: ClientService
    @State private var workouts: WorkoutService
    @State private var exercises: ExerciseLibraryService

    init() {
        let b = MockBackendService()
        _backend = State(initialValue: b)
        _auth = State(initialValue: AuthService(backend: b))
        _clients = State(initialValue: ClientService(backend: b))
        _workouts = State(initialValue: WorkoutService(backend: b))
        _exercises = State(initialValue: ExerciseLibraryService(backend: b))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isSignedIn && auth.isTrainer {
                    TrainerRootView(auth: auth, clients: clients, workouts: workouts, exercises: exercises)
                } else {
                    TrainerAuthView(auth: auth)
                }
            }
        }
        .modelContainer(for: [User.self, ClientProfile.self, Exercise.self, Workout.self, WorkoutBlock.self,
                              WorkoutExercise.self, ScheduledWorkout.self, WorkoutSession.self,
                              LoggedExercise.self, LoggedSet.self, BodyMetric.self, PersonalRecord.self])
    }
}
