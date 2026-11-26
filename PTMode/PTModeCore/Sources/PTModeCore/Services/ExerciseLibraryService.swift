import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public final class ExerciseLibraryService {
    public private(set) var exercises: [Exercise] = []
    public var searchText: String = ""
    public var selectedMuscle: MuscleGroup?
    public var selectedEquipment: Equipment?

    private let backend: BackendService
    public init(backend: BackendService) { self.backend = backend }

    public var filtered: [Exercise] {
        exercises.filter { ex in
            (searchText.isEmpty || ex.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedMuscle == nil || ex.muscleGroup == selectedMuscle) &&
            (selectedEquipment == nil || ex.equipment == selectedEquipment)
        }
    }

    public func load(trainerID: UUID?) async {
        do { exercises = try await backend.fetchExercises(trainerID: trainerID) }
        catch { exercises = Exercise.seedLibrary }
    }

    public func save(_ exercise: Exercise) async {
        if let i = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[i] = exercise
        } else {
            exercises.append(exercise)
        }
        do { try await backend.saveExercise(exercise) } catch {}
    }
}
