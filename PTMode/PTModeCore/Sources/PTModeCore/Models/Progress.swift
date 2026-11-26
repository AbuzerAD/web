import Foundation
import SwiftData

/// A body-metric snapshot for a client over time.
@Model
public final class BodyMetric {
    public var id: UUID
    public var clientID: UUID
    public var recordedAt: Date
    public var weightKg: Double?
    public var bodyFatPct: Double?
    public var chestCm: Double?
    public var waistCm: Double?
    public var hipsCm: Double?
    public var armsCm: Double?
    public var thighsCm: Double?
    public var notes: String

    public init(
        id: UUID = UUID(),
        clientID: UUID,
        recordedAt: Date = .now,
        weightKg: Double? = nil,
        bodyFatPct: Double? = nil,
        chestCm: Double? = nil,
        waistCm: Double? = nil,
        hipsCm: Double? = nil,
        armsCm: Double? = nil,
        thighsCm: Double? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.clientID = clientID
        self.recordedAt = recordedAt
        self.weightKg = weightKg
        self.bodyFatPct = bodyFatPct
        self.chestCm = chestCm
        self.waistCm = waistCm
        self.hipsCm = hipsCm
        self.armsCm = armsCm
        self.thighsCm = thighsCm
        self.notes = notes
    }
}

/// A personal record for an exercise.
@Model
public final class PersonalRecord {
    public var id: UUID
    public var clientID: UUID
    public var exerciseID: UUID
    public var exerciseName: String
    public var weightKg: Double
    public var reps: Int
    public var achievedAt: Date
    public var sessionID: UUID?

    public init(
        id: UUID = UUID(),
        clientID: UUID,
        exerciseID: UUID,
        exerciseName: String,
        weightKg: Double,
        reps: Int,
        achievedAt: Date = .now,
        sessionID: UUID? = nil
    ) {
        self.id = id
        self.clientID = clientID
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.weightKg = weightKg
        self.reps = reps
        self.achievedAt = achievedAt
        self.sessionID = sessionID
    }
}
