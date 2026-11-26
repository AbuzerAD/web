import Foundation
import SwiftData

/// A single exercise in the library. Shared across both apps.
@Model
public final class Exercise {
    public var id: UUID
    public var name: String
    public var muscleGroup: MuscleGroup
    public var secondaryMuscles: [MuscleGroup]
    public var equipment: Equipment
    public var difficulty: Difficulty
    public var instructions: String
    public var tips: String
    public var imageURL: URL?
    public var videoURL: URL?
    public var isCustom: Bool          // trainer-created
    public var createdByTrainerID: UUID?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        secondaryMuscles: [MuscleGroup] = [],
        equipment: Equipment = .bodyweight,
        difficulty: Difficulty = .beginner,
        instructions: String = "",
        tips: String = "",
        imageURL: URL? = nil,
        videoURL: URL? = nil,
        isCustom: Bool = false,
        createdByTrainerID: UUID? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.difficulty = difficulty
        self.instructions = instructions
        self.tips = tips
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.isCustom = isCustom
        self.createdByTrainerID = createdByTrainerID
        self.createdAt = createdAt
    }
}

public enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case chest, back, shoulders, biceps, triceps, forearms
    case quads, hamstrings, glutes, calves, core, fullBody, cardio
}

public enum Equipment: String, Codable, CaseIterable, Sendable {
    case bodyweight, dumbbell, barbell, kettlebell, machine, cable, band, other
}

public enum Difficulty: String, Codable, CaseIterable, Sendable {
    case beginner, intermediate, advanced
}
