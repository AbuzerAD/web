import SwiftUI

struct WorkoutPlayerView: View {
    let scheduled: ScheduledWorkout
    let workouts: WorkoutService
    let sessions: SessionService
    let clientID: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var workout: Workout?
    @State private var session: WorkoutSession?
    @State private var blockIndex = 0
    @State private var exerciseIndex = 0
    @State private var setIndex = 0
    @State private var restRemaining = 0
    @State private var isResting = false
    @State private var restTimer: Timer?
    @State private var repsInput = ""
    @State private var weightInput = ""
    @State private var showFinish = false

    private var currentBlock: WorkoutBlock? {
        guard let w = workout, blockIndex < w.blocks.count else { return nil }
        return w.blocks[blockIndex]
    }
    private var currentExercise: WorkoutExercise? {
        guard let b = currentBlock, exerciseIndex < b.exercises.count else { return nil }
        return b.exercises[exerciseIndex]
    }

    var body: some View {
        ZStack {
            PTTheme.Colors.background.ignoresSafeArea()
            if isResting {
                restView
            } else if let ex = currentExercise {
                exerciseView(ex)
            } else {
                finishedView
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: { Image(systemName: "xmark") }
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private func exerciseView(_ ex: WorkoutExercise) -> some View {
        ScrollView {
            VStack(spacing: PTTheme.Spacing.lg) {
                VStack(spacing: 4) {
                    Text(currentBlock?.title ?? "").font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                    Text(ex.exerciseName).font(PTTheme.Typography.title)
                    Text("Set \(setIndex + 1) of \(ex.sets)").font(PTTheme.Typography.headline).foregroundStyle(PTTheme.Colors.primary)
                }
                .padding(.top)

                PTCard {
                    VStack(spacing: PTTheme.Spacing.md) {
                        HStack {
                            VStack { Text("Reps").font(PTTheme.Typography.caption); Text(ex.reps).font(PTTheme.Typography.title2) }
                            Spacer()
                            VStack { Text("Rest").font(PTTheme.Typography.caption); Text("\(ex.restSec)s").font(PTTheme.Typography.title2) }
                            Spacer()
                            if let w = ex.weightKg { VStack { Text("Weight").font(PTTheme.Typography.caption); Text(String(format: "%.1f", w)).font(PTTheme.Typography.title2) } }
                        }
                        if !ex.notes.isEmpty {
                            Text(ex.notes).font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal)

                PTCard {
                    VStack(spacing: PTTheme.Spacing.md) {
                        HStack {
                            TextField("Reps done", text: $repsInput).keyboardType(.numberPad)
                                .padding().background(PTTheme.Colors.background).clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.sm))
                            TextField("Weight kg", text: $weightInput).keyboardType(.decimalPad)
                                .padding().background(PTTheme.Colors.background).clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.sm))
                        }
                        PTButton("Complete Set") { completeSet(ex) }
                    }
                }
                .padding(.horizontal)

                PTButton("Skip exercise", style: .ghost) { skipExercise() }
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var restView: some View {
        VStack(spacing: PTTheme.Spacing.xl) {
            Text("Rest").font(PTTheme.Typography.title).foregroundStyle(PTTheme.Colors.rest)
            Text("\(restRemaining)").font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(PTTheme.Colors.rest)
            PTButton("Skip rest") { endRest() }.padding(.horizontal, 40)
        }
    }

    private var finishedView: some View {
        VStack(spacing: PTTheme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 72)).foregroundStyle(PTTheme.Colors.success)
            Text("Workout complete!").font(PTTheme.Typography.title)
            PTButton("Finish") {
                Task {
                    if let s = session { s.status = .completed; s.finishedAt = .now; await sessions.save(s) }
                    dismiss()
                }
            }
            .padding(.horizontal, 40)
        }
    }

    private func load() async {
        await workouts.load(trainerID: UUID())
        workout = workouts.workouts.first { $0.id == scheduled.workoutID }
        if let w = workout {
            let s = WorkoutSession(clientID: clientID, trainerID: scheduled.trainerID,
                                  scheduledWorkoutID: scheduled.id, workoutID: w.id, workoutName: w.name)
            // prepare logged exercises
            s.loggedExercises = w.blocks.flatMap { $0.exercises }.map { we in
                LoggedExercise(exerciseID: we.exerciseID, exerciseName: we.exerciseName, order: we.order)
            }
            session = s
            await sessions.save(s)
        }
        if let ex = currentExercise {
            repsInput = ex.reps.filter { $0.isNumber }
            weightInput = ex.weightKg.map { String(format: "%.1f", $0) } ?? ""
        }
    }

    private func completeSet(_ ex: WorkoutExercise) {
        let reps = Int(repsInput) ?? 0
        let weight = Double(weightInput) ?? 0
        // log
        if let s = session {
            if let li = s.loggedExercises.firstIndex(where: { $0.exerciseID == ex.exerciseID }) {
                let set = LoggedSet(index: setIndex, reps: reps, weightKg: weight)
                s.loggedExercises[li].sets.append(set)
            }
        }
        if setIndex + 1 < ex.sets {
            setIndex += 1
            startRest(seconds: ex.restSec)
        } else {
            // next exercise
            advanceExercise()
        }
    }

    private func startRest(seconds: Int) {
        restRemaining = seconds
        isResting = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if restRemaining > 0 { restRemaining -= 1 } else { endRest() }
        }
    }

    private func endRest() {
        restTimer?.invalidate()
        isResting = false
        if let ex = currentExercise {
            repsInput = ex.reps.filter { $0.isNumber }
            weightInput = ex.weightKg.map { String(format: "%.1f", $0) } ?? ""
        }
    }

    private func advanceExercise() {
        guard let b = currentBlock else { return }
        if exerciseIndex + 1 < b.exercises.count {
            exerciseIndex += 1
            setIndex = 0
        } else if blockIndex + 1 < (workout?.blocks.count ?? 0) {
            blockIndex += 1
            exerciseIndex = 0
            setIndex = 0
        } else {
            // done
            exerciseIndex = b.exercises.count // mark finished
        }
        if let ex = currentExercise {
            repsInput = ex.reps.filter { $0.isNumber }
            weightInput = ex.weightKg.map { String(format: "%.1f", $0) } ?? ""
        }
    }

    private func skipExercise() { advanceExercise() }
}
