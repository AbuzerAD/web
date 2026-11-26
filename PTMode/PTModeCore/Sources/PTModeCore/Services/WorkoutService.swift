import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public final class WorkoutService {
    public private(set) var workouts: [Workout] = []
    private let backend: BackendService

    public init(backend: BackendService) { self.backend = backend }

    public func load(trainerID: UUID) async {
        do { workouts = try await backend.fetchWorkouts(trainerID: trainerID) } catch { workouts = [] }
    }

    public func save(_ workout: Workout) async {
        workout.updatedAt = .now
        if let i = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[i] = workout
        } else {
            workouts.append(workout)
        }
        do { try await backend.saveWorkout(workout) } catch {}
    }

    public func delete(id: UUID) async {
        workouts.removeAll { $0.id == id }
        do { try await backend.deleteWorkout(id: id) } catch {}
    }

    public func assign(_ scheduled: ScheduledWorkout) async {
        do { try await backend.assignWorkout(scheduled) } catch {}
    }
}
