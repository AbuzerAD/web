import SwiftUI

struct WorkoutBuilderView: View {
    let workouts: WorkoutService
    let exercises: ExerciseLibraryService
    let existing: Workout?

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var summary = ""
    @State private var minutes = 45
    @State private var difficulty: Difficulty = .intermediate
    @State private var blocks: [WorkoutBlock] = [WorkoutBlock(title: "Main", kind: .main)]
    @State private var showExercisePicker = false
    @State private var targetBlockID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Workout name", text: $name)
                    TextField("Summary", text: $summary)
                    Stepper("Estimated minutes: \(minutes)", value: $minutes, in: 5...180, step: 5)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                }

                ForEach($blocks) { $block in
                    Section {
                        ForEach(block.exercises.sorted { $0.order < $1.order }) { we in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(we.exerciseName).font(PTTheme.Typography.headline)
                                    Text("\(we.sets) × \(we.reps)")
                                        .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete { idx in
                            let sorted = block.exercises.sorted { $0.order < $1.order }
                            for i in idx {
                                if let j = block.exercises.firstIndex(where: { $0.id == sorted[i].id }) {
                                    block.exercises.remove(at: j)
                                }
                            }
                        }
                        Button {
                            targetBlockID = block.id
                            showExercisePicker = true
                        } label: {
                            Label("Add exercise", systemImage: "plus.circle")
                        }
                    } header: {
                        TextField("Block title", text: $block.title)
                    }
                }

                Section {
                    Button {
                        blocks.append(WorkoutBlock(title: "New block", kind: .main))
                    } label: { Label("Add block", systemImage: "plus.rectangle.on.rectangle") }
                }
            }
            .navigationTitle(existing == nil ? "New Workout" : "Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView(exercises: exercises) { picked in
                    guard let bid = targetBlockID,
                          let bi = blocks.firstIndex(where: { $0.id == bid }) else { return }
                    let we = WorkoutExercise(
                        exerciseID: picked.id,
                        exerciseName: picked.name,
                        order: blocks[bi].exercises.count,
                        sets: 3, reps: "10", restSec: 60
                    )
                    blocks[bi].exercises.append(we)
                }
            }
            .task {
                await exercises.load(trainerID: nil)
                if let e = existing {
                    name = e.name; summary = e.summary; minutes = e.estimatedMinutes
                    difficulty = e.difficulty; blocks = e.blocks
                }
            }
        }
    }

    private func save() {
        let trainerID = UUID()
        let w = existing ?? Workout(name: name, trainerID: trainerID)
        w.name = name; w.summary = summary; w.estimatedMinutes = minutes
        w.difficulty = difficulty; w.blocks = blocks
        Task {
            await workouts.save(w)
            dismiss()
        }
    }
}

struct ExercisePickerView: View {
    let exercises: ExerciseLibraryService
    let onPick: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List(exercises.filtered) { ex in
                Button {
                    onPick(ex); dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(ex.name).font(PTTheme.Typography.headline)
                        Text("\(ex.muscleGroup.rawValue.capitalized) · \(ex.equipment.rawValue)")
                            .font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                    }
                }
            }
            .searchable(text: $search)
            .onChange(of: search) { _, v in exercises.searchText = v }
            .navigationTitle("Pick exercise")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
