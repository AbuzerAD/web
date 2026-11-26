import SwiftUI

struct ProgressViewScreen: View {
    let progress: ProgressService
    let sessions: SessionService
    let auth: AuthService
    @State private var showAddMetric = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PTTheme.Spacing.lg) {
                    PTSectionHeader("Body metrics").padding(.horizontal)
                    if progress.metrics.isEmpty {
                        PTEmptyState(icon: "scalemass", title: "No metrics yet",
                                     message: "Log your weight and measurements.")
                            .padding(.horizontal)
                    } else {
                        ForEach(progress.metrics.sorted { $0.recordedAt > $1.recordedAt }) { m in
                            PTCard {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(m.recordedAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(PTTheme.Typography.headline)
                                    HStack {
                                        if let w = m.weightKg { Text(String(format: "Weight %.1f kg", w)) }
                                        if let bf = m.bodyFatPct { Text(String(format: "BF %.1f%%", bf)) }
                                    }
                                    .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    PTSectionHeader("Personal records").padding(.horizontal)
                    if progress.records.isEmpty {
                        PTEmptyState(icon: "trophy", title: "No PRs yet",
                                     message: "Your best lifts will show here.")
                            .padding(.horizontal)
                    } else {
                        ForEach(progress.records) { r in
                            PTCard {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(r.exerciseName).font(PTTheme.Typography.headline)
                                        Text(r.achievedAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Text(String(format: "%.1f kg × %d", r.weightKg, r.reps))
                                        .font(PTTheme.Typography.headline).foregroundStyle(PTTheme.Colors.primary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    PTSectionHeader("Summary").padding(.horizontal)
                    PTCard {
                        VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                            Text("Sessions completed: \(sessions.sessions.filter { $0.status == .completed }.count)")
                            Text("Total volume tracked via sessions")
                                .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(PTTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddMetric = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddMetric) {
                AddMetricView(progress: progress, clientID: auth.currentUser?.id ?? UUID())
            }
            .task {
                await progress.load(clientID: auth.currentUser?.id ?? UUID(), sessionService: sessions)
            }
        }
    }
}

struct AddMetricView: View {
    let progress: ProgressService
    let clientID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var waist = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Weight (kg)", text: $weight).keyboardType(.decimalPad)
                TextField("Body fat %", text: $bodyFat).keyboardType(.decimalPad)
                TextField("Waist (cm)", text: $waist).keyboardType(.decimalPad)
            }
            .navigationTitle("Log metric")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let m = BodyMetric(clientID: clientID,
                           weightKg: Double(weight),
                           bodyFatPct: Double(bodyFat),
                           waistCm: Double(waist))
        Task { await progress.addMetric(m); dismiss() }
    }
}
