import Foundation
import SwiftData

/// An actual performed session by a client, with logged sets.
@Model
public final class WorkoutSession {
    public var id: UUID
    public var clientID: UUID
    public var trainerID: UUID?
    public var scheduledWorkoutID: UUID?
    public var workoutID: UUID
    public var workoutName: String
    public var startedAt: Date
    public var finishedAt: Date?
    public var status: SessionStatus
    public var perceivedExertion: Int?   // RPE 1-10
    public var mood: Mood?
    public var notes: String
    public var loggedExercises: [LoggedExercise]

    public init(
        id: UUID = UUID(),
        clientID: UUID,
        trainerID: UUID? = nil,
        scheduledWorkoutID: UUID? = nil,
        workoutID: UUID,
        workoutName: String,
        startedAt: Date = .now,
        finishedAt: Date? = nil,
        status: SessionStatus = .inProgress,
        perceivedExertion: Int? = nil,
        mood: Mood? = nil,
        notes: String = "",
        loggedExercises: [LoggedExercise] = []
    ) {
        self.id = id
        self.clientID = clientID
        self.trainerID = trainerID
        self.scheduledWorkoutID = scheduledWorkoutID
        self.workoutID = workoutID
        self.workoutName = workoutName
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.status = status
        self.perceivedExertion = perceivedExertion
        self.mood = mood
        self.notes = notes
        self.loggedExercises = loggedExercises
    }

    public var durationMinutes: Int? {
        guard let end = finishedAt else { return nil }
        return Int(end.timeIntervalSince(startedAt) / 60)
    }
}

@Model
public final class LoggedExercise {
    public var id: UUID
    public var exerciseID: UUID
    public var exerciseName: String
    public var order: Int
    public var sets: [LoggedSet]
    public var notes: String

    public init(
        id: UUID = UUID(),
        exerciseID: UUID,
        exerciseName: String,
        order: Int = 0,
        sets: [LoggedSet] = [],
        notes: String = ""
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.order = order
        self.sets = sets
        self.notes = notes
    }
}

@Model
public final class LoggedSet {
    public var id: UUID
    public var index: Int
    public var reps: Int
    public var weightKg: Double
    public var rpe: Int?          // 1-10
    public var completed: Bool
    public var restTakenSec: Int?

    public init(
        id: UUID = UUID(),
        index: Int,
        reps: Int,
        weightKg: Double,
        rpe: Int? = nil,
        completed: Bool = true,
        restTakenSec: Int? = nil
    ) {
        self.id = id
        self.index = index
        self.reps = reps
        self.weightKg = weightKg
        self.rpe = rpe
        self.completed = completed
        self.restTakenSec = restTakenSec
    }
}

public enum SessionStatus: String, Codable, CaseIterable, Sendable {
    case inProgress, completed, abandoned
}

public enum Mood: String, Codable, CaseIterable, Sendable {
    case great, good, okay, tired, exhausted
}
