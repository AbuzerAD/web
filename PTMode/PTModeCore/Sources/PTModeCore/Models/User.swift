import Foundation
import SwiftData

/// The two kinds of people who use PTMode.
public enum UserRole: String, Codable, CaseIterable, Sendable {
    case trainer
    case client
}

/// A person. Trainers own clients; clients are linked to a trainer.
@Model
public final class User {
    public var id: UUID
    public var role: UserRole
    public var fullName: String
    public var email: String
    public var phone: String?
    public var avatarURL: URL?
    public var createdAt: Date
    public var trainerID: UUID?   // for clients: their trainer

    public init(
        id: UUID = UUID(),
        role: UserRole,
        fullName: String,
        email: String,
        phone: String? = nil,
        avatarURL: URL? = nil,
        createdAt: Date = .now,
        trainerID: UUID? = nil
    ) {
        self.id = id
        self.role = role
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.trainerID = trainerID
    }
}

/// Extended profile captured during client onboarding.
@Model
public final class ClientProfile {
    public var id: UUID
    public var userID: UUID
    public var dateOfBirth: Date?
    public var heightCm: Double?
    public var weightKg: Double?
    public var fitnessLevel: FitnessLevel
    public var goals: [String]
    public var injuries: [String]
    public var notes: String
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userID: UUID,
        dateOfBirth: Date? = nil,
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        fitnessLevel: FitnessLevel = .beginner,
        goals: [String] = [],
        injuries: [String] = [],
        notes: String = "",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userID = userID
        self.dateOfBirth = dateOfBirth
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.fitnessLevel = fitnessLevel
        self.goals = goals
        self.injuries = injuries
        self.notes = notes
        self.updatedAt = updatedAt
    }
}

public enum FitnessLevel: String, Codable, CaseIterable, Sendable {
    case beginner, intermediate, advanced, athlete
}
