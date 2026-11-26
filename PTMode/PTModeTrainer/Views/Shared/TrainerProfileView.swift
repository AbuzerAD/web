import SwiftUI

struct TrainerProfileView: View {
    let auth: AuthService
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Circle().fill(PTTheme.Colors.primary.opacity(0.15)).frame(width: 60, height: 60)
                            .overlay(Text("PT").font(PTTheme.Typography.title).foregroundStyle(PTTheme.Colors.primary))
                        VStack(alignment: .leading) {
                            Text(auth.currentUser?.fullName ?? "Trainer").font(PTTheme.Typography.headline)
                            Text(auth.currentUser?.email ?? "").font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                        }
                    }
                }
                Section {
                    Button("Sign out", role: .destructive) { Task { await auth.signOut() } }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
