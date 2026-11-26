import SwiftUI

struct ExerciseLibraryView: View {
    @Bindable var service: ExerciseLibraryService
    let trainerMode: Bool
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if service.exercises.isEmpty {
                    PTEmptyState(icon: "figure.strengthtraining.traditional", title: "No exercises",
                                 message: "Add exercises to your library.")
                } else {
                    List(service.filtered) { ex in
                        NavigationLink {
                            ExerciseDetailView(exercise: ex, service: service, trainerMode: trainerMode)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ex.name).font(PTTheme.Typography.headline)
                                Text("\(ex.muscleGroup.rawValue.capitalized) · \(ex.equipment.rawValue) · \(ex.difficulty.rawValue)")
                                    .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $service.searchText, prompt: "Search")
            .toolbar {
                if trainerMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showEditor = true } label: { Image(systemName: "plus") }
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                ExerciseEditorView(service: service, existing: nil)
            }
            .task { await service.load(trainerID: nil) }
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    let service: ExerciseLibraryService
    let trainerMode: Bool
    @State private var showEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PTTheme.Spacing.lg) {
                PTCard {
                    VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                        Text(exercise.name).font(PTTheme.Typography.title)
                        HStack {
                            PTPill(exercise.muscleGroup.rawValue.capitalized)
                            PTPill(exercise.equipment.rawValue, color: PTTheme.Colors.accent)
                            PTPill(exercise.difficulty.rawValue.capitalized, color: PTTheme.Colors.warning)
                        }
                        if let img = exercise.imageURL {
                            AsyncImage(url: img) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
                                .frame(height: 180).clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                        }
                    }
                }
                .padding(.horizontal)

                if !exercise.instructions.isEmpty {
                    PTCard {
                        VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                            Text("Instructions").font(PTTheme.Typography.headline)
                            Text(exercise.instructions).font(PTTheme.Typography.body)
                        }
                    }
                    .padding(.horizontal)
                }
                if !exercise.tips.isEmpty {
                    PTCard {
                        VStack(alignment: .leading, spacing: PTTheme.Spacing.sm) {
                            Text("Tips").font(PTTheme.Typography.headline)
                            Text(exercise.tips).font(PTTheme.Typography.body)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(PTTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if trainerMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { showEditor = true }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            ExerciseEditorView(service: service, existing: exercise)
        }
    }
}

struct ExerciseEditorView: View {
    let service: ExerciseLibraryService
    let existing: Exercise?
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var muscle: MuscleGroup = .chest
    @State private var equipment: Equipment = .bodyweight
    @State private var difficulty: Difficulty = .beginner
    @State private var instructions = ""
    @State private var tips = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Muscle group", selection: $muscle) {
                    ForEach(MuscleGroup.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                Picker("Equipment", selection: $equipment) {
                    ForEach(Equipment.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                Section("Instructions") { TextEditor(text: $instructions).frame(minHeight: 80) }
                Section("Tips") { TextEditor(text: $tips).frame(minHeight: 60) }
            }
            .navigationTitle(existing == nil ? "New Exercise" : "Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.isEmpty)
                }
            }
            .task {
                if let e = existing {
                    name = e.name; muscle = e.muscleGroup; equipment = e.equipment
                    difficulty = e.difficulty; instructions = e.instructions; tips = e.tips
                }
            }
        }
    }

    private func save() {
        let ex = existing ?? Exercise(name: name, muscleGroup: muscle, isCustom: true)
        ex.name = name; ex.muscleGroup = muscle; ex.equipment = equipment
        ex.difficulty = difficulty; ex.instructions = instructions; ex.tips = tips
        Task { await service.save(ex); dismiss() }
    }
}
