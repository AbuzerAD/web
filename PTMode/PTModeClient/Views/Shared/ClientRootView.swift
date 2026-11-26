import SwiftUI

struct ClientRootView: View {
    let auth: AuthService
    let exercises: ExerciseLibraryService
    let workouts: WorkoutService
    let sessions: SessionService
    let progress: ProgressService

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(auth: auth, workouts: workouts, sessions: sessions)
                .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            HistoryView(sessions: sessions)
                .tabItem { Label("History", systemImage: "clock.fill") }.tag(1)
            ProgressViewScreen(progress: progress, sessions: sessions, auth: auth)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }.tag(2)
            ClientProfileView(auth: auth)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(3)
        }
        .tint(PTTheme.Colors.primary)
    }
}
