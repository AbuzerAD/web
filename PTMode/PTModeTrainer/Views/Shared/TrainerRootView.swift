import SwiftUI

struct TrainerRootView: View {
    let auth: AuthService
    let clients: ClientService
    let workouts: WorkoutService
    let exercises: ExerciseLibraryService

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ClientsListView(clients: clients, workouts: workouts)
                .tabItem { Label("Clients", systemImage: "person.2.fill") }
                .tag(0)

            WorkoutsListView(workouts: workouts, exercises: exercises)
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
                .tag(1)

            ExerciseLibraryView(service: exercises, trainerMode: true)
                .tabItem { Label("Exercises", systemImage: "figure.strengthtraining.traditional") }
                .tag(2)

            TrainerProfileView(auth: auth)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(3)
        }
        .tint(PTTheme.Colors.primary)
    }
}
