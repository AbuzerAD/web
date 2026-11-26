import Foundation

/// Abstraction over the remote backend. Swap Supabase/Firebase/custom here.
@MainActor
public protocol BackendService: AnyObject {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, role: UserRole, fullName: String) async throws -> User
    func signOut() async throws

    func fetchClients(trainerID: UUID) async throws -> [User]
    func createClient(_ client: User, profile: ClientProfile) async throws
    func updateClientProfile(_ profile: ClientProfile) async throws

    func fetchExercises(trainerID: UUID?) async throws -> [Exercise]
    func saveExercise(_ exercise: Exercise) async throws

    func fetchWorkouts(trainerID: UUID) async throws -> [Workout]
    func saveWorkout(_ workout: Workout) async throws
    func deleteWorkout(id: UUID) async throws

    func assignWorkout(_ scheduled: ScheduledWorkout) async throws
    func fetchScheduled(clientID: UUID) async throws -> [ScheduledWorkout]

    func saveSession(_ session: WorkoutSession) async throws
    func fetchSessions(clientID: UUID) async throws -> [WorkoutSession]

    func saveBodyMetric(_ metric: BodyMetric) async throws
    func fetchBodyMetrics(clientID: UUID) async throws -> [BodyMetric]

    func savePersonalRecord(_ record: PersonalRecord) async throws
}

/// A no-op in-memory backend used for previews and offline-first dev.
@MainActor
public final class MockBackendService: BackendService {
    private var users: [UUID: User] = [:]
    private var clients: [UUID: [User]] = [:]
    private var exercises: [Exercise] = Exercise.seedLibrary
    private var workouts: [UUID: [Workout]] = [:]
    private var scheduledStore: [ScheduledWorkout] = []
    private var sessionsStore: [WorkoutSession] = []
    private var metricsStore: [BodyMetric] = []
    private var records: [PersonalRecord] = []

    public init() {}

    public func signIn(email: String, password: String) async throws -> User {
        if let u = users.values.first(where: { $0.email == email }) { return u }
        throw BackendError.notFound
    }
    public func signUp(email: String, password: String, role: UserRole, fullName: String) async throws -> User {
        let u = User(role: role, fullName: fullName, email: email)
        users[u.id] = u
        return u
    }
    public func signOut() async throws {}

    public func fetchClients(trainerID: UUID) async throws -> [User] {
        clients.values.flatMap { $0 }
    }
    public func createClient(_ client: User, profile: ClientProfile) async throws {
        var list = clients[client.trainerID ?? UUID()] ?? []
        list.append(client)
        clients[client.trainerID ?? UUID()] = list
        _ = profile
    }
    public func updateClientProfile(_ profile: ClientProfile) async throws {}

    public func fetchExercises(trainerID: UUID?) async throws -> [Exercise] {
        exercises
    }
    public func saveExercise(_ exercise: Exercise) async throws {
        if let i = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[i] = exercise
        } else {
            exercises.append(exercise)
        }
    }

    public func fetchWorkouts(trainerID: UUID) async throws -> [Workout] {
        workouts.values.flatMap { $0 }
    }
    public func saveWorkout(_ workout: Workout) async throws {
        workout.updatedAt = .now
        var list = workouts[workout.trainerID] ?? []
        if let i = list.firstIndex(where: { $0.id == workout.id }) {
            list[i] = workout
        } else {
            list.append(workout)
        }
        workouts[workout.trainerID] = list
    }
    public func deleteWorkout(id: UUID) async throws {
        for k in workouts.keys {
            workouts[k]?.removeAll { $0.id == id }
        }
    }

    public func assignWorkout(_ scheduled: ScheduledWorkout) async throws {
        scheduledStore.append(scheduled)
    }
    public func fetchScheduled(clientID: UUID) async throws -> [ScheduledWorkout] {
        scheduledStore.filter { $0.clientID == clientID }
    }

    public func saveSession(_ session: WorkoutSession) async throws {
        sessionsStore.append(session)
    }
    public func fetchSessions(clientID: UUID) async throws -> [WorkoutSession] {
        sessionsStore.filter { $0.clientID == clientID }
    }

    public func saveBodyMetric(_ metric: BodyMetric) async throws {
        metricsStore.append(metric)
    }
    public func fetchBodyMetrics(clientID: UUID) async throws -> [BodyMetric] {
        metricsStore.filter { $0.clientID == clientID }
    }

    public func savePersonalRecord(_ record: PersonalRecord) async throws {
        records.append(record)
    }
}

public enum BackendError: Error, LocalizedError {
    case notFound, unauthorized, network, unknown(String)
    public var errorDescription: String? {
        switch self {
        case .notFound: return "Not found"
        case .unauthorized: return "Unauthorized"
        case .network: return "Network error"
        case .unknown(let m): return m
        }
    }
}
