import SwiftUI
import SwiftData

@main
struct PTModeClientApp: App {
    @State private var backend = MockBackendService()
    @State private var auth: AuthService
    @State private var exercises: ExerciseLibraryService
    @State private var workouts: WorkoutService
    @State private var sessions: SessionService
    @State private var progress: ProgressService

    init() {
        let b = MockBackendService()
        _backend = State(initialValue: b)
        _auth = State(initialValue: AuthService(backend: b))
        _exercises = State(initialValue: ExerciseLibraryService(backend: b))
        _workouts = State(initialValue: WorkoutService(backend: b))
        _sessions = State(initialValue: SessionService(backend: b))
        _progress = State(initialValue: ProgressService(backend: b))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isSignedIn && auth.isClient {
                    ClientRootView(auth: auth, exercises: exercises, workouts: workouts,
                                   sessions: sessions, progress: progress)
                } else {
                    ClientAuthView(auth: auth)
                }
            }
        }
        .modelContainer(for: [User.self, ClientProfile.self, Exercise.self, Workout.self, WorkoutBlock.self,
                              WorkoutExercise.self, ScheduledWorkout.self, WorkoutSession.self,
                              LoggedExercise.self, LoggedSet.self, BodyMetric.self, PersonalRecord.self])
    }
}
