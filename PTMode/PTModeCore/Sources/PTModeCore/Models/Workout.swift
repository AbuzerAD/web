import Foundation
import SwiftData

/// A reusable workout template created by a trainer.
@Model
public final class Workout {
    public var id: UUID
    public var name: String
    public var summary: String
    public var trainerID: UUID
    public var estimatedMinutes: Int
    public var difficulty: Difficulty
    public var blocks: [WorkoutBlock]
    public var isTemplate: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        summary: String = "",
        trainerID: UUID,
        estimatedMinutes: Int = 45,
        difficulty: Difficulty = .intermediate,
        blocks: [WorkoutBlock] = [],
        isTemplate: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.trainerID = trainerID
        self.estimatedMinutes = estimatedMinutes
        self.difficulty = difficulty
        self.blocks = blocks
        self.isTemplate = isTemplate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var totalExercises: Int { blocks.flatMap(\.exercises).count }
}

/// A grouping inside a workout (warm-up, main, cool-down, superset).
@Model
public final class WorkoutBlock {
    public var id: UUID
    public var title: String
    public var kind: BlockKind
    public var exercises: [WorkoutExercise]
    public var restBetweenExercisesSec: Int
    public var notes: String

    public init(
        id: UUID = UUID(),
        title: String,
        kind: BlockKind = .main,
        exercises: [WorkoutExercise] = [],
        restBetweenExercisesSec: Int = 60,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.exercises = exercises
        self.restBetweenExercisesSec = restBetweenExercisesSec
        self.notes = notes
    }
}

public enum BlockKind: String, Codable, CaseIterable, Sendable {
    case warmup, main, cooldown, superset, circuit
}

/// An exercise placed inside a workout with prescription.
@Model
public final class WorkoutExercise {
    public var id: UUID
    public var exerciseID: UUID
    public var exerciseName: String   // denormalized for offline
    public var order: Int
    public var sets: Int
    public var reps: String           // "8-10", "AMRAP", "30s"
    public var weightKg: Double?      // prescribed
    public var restSec: Int
    public var tempo: String?         // "3-1-1-0"
    public var notes: String

    public init(
        id: UUID = UUID(),
        exerciseID: UUID,
        exerciseName: String,
        order: Int = 0,
        sets: Int = 3,
        reps: String = "10",
        weightKg: Double? = nil,
        restSec: Int = 60,
        tempo: String? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.order = order
        self.sets = sets
        self.reps = reps
        self.weightKg = weightKg
        self.restSec = restSec
        self.tempo = tempo
        self.notes = notes
    }
}

/// A workout assigned to a client on a date.
@Model
public final class ScheduledWorkout {
    public var id: UUID
    public var clientID: UUID
    public var trainerID: UUID
    public var workoutID: UUID
    public var workoutName: String
    public var scheduledDate: Date
    public var status: ScheduleStatus
    public var notes: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        clientID: UUID,
        trainerID: UUID,
        workoutID: UUID,
        workoutName: String,
        scheduledDate: Date,
        status: ScheduleStatus = .planned,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.clientID = clientID
        self.trainerID = trainerID
        self.workoutID = workoutID
        self.workoutName = workoutName
        self.scheduledDate = scheduledDate
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }
}

public enum ScheduleStatus: String, Codable, CaseIterable, Sendable {
    case planned, inProgress, completed, skipped, cancelled
}
