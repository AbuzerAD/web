import SwiftUI

struct ClientsListView: View {
    let clients: ClientService
    let workouts: WorkoutService
    @State private var showOnboard = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if clients.clients.isEmpty {
                    PTEmptyState(icon: "person.2", title: "No clients yet",
                                 message: "Onboard your first client to start coaching.")
                } else {
                    List {
                        ForEach(filtered) { client in
                            NavigationLink {
                                ClientDetailView(client: client, clients: clients, workouts: workouts)
                            } label: {
                                ClientRow(client: client)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Clients")
            .searchable(text: $searchText, prompt: "Search clients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showOnboard = true } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showOnboard) {
                ClientOnboardingView(clients: clients)
            }
            .task { await clients.load(trainerID: UUID()) }
        }
    }

    private var filtered: [User] {
        guard !searchText.isEmpty else { return clients.clients }
        return clients.clients.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }
}

struct ClientRow: View {
    let client: User
    var body: some View {
        HStack(spacing: PTTheme.Spacing.md) {
            Circle()
                .fill(PTTheme.Colors.primary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(Text(initials).font(PTTheme.Typography.headline).foregroundStyle(PTTheme.Colors.primary))
            VStack(alignment: .leading, spacing: 2) {
                Text(client.fullName).font(PTTheme.Typography.headline)
                Text(client.email).font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
            }
            Spacer()
        }
    }
    private var initials: String {
        client.fullName.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
    }
}
