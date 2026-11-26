import Foundation

extension Exercise {
    /// A starter exercise library so the app is usable offline out of the box.
    public static var seedLibrary: [Exercise] {
        [
            Exercise(name: "Push-Up", muscleGroup: .chest, secondaryMuscles: [.triceps, .shoulders], equipment: .bodyweight, difficulty: .beginner,
                     instructions: "Hands under shoulders, body in a straight line. Lower chest to floor, push back up.",
                     tips: "Keep core tight; don't let hips sag."),
            Exercise(name: "Bench Press", muscleGroup: .chest, secondaryMuscles: [.triceps, .shoulders], equipment: .barbell, difficulty: .intermediate,
                     instructions: "Lie on bench, grip bar slightly wider than shoulders. Lower to mid-chest, press up.",
                     tips: "Feet flat; slight arch in lower back."),
            Exercise(name: "Dumbbell Row", muscleGroup: .back, secondaryMuscles: [.biceps], equipment: .dumbbell, difficulty: .beginner,
                     instructions: "Hinge forward, pull dumbbell to hip, squeeze shoulder blade."),
            Exercise(name: "Pull-Up", muscleGroup: .back, secondaryMuscles: [.biceps], equipment: .bodyweight, difficulty: .advanced,
                     instructions: "Hang from bar, pull chin over bar, lower with control."),
            Exercise(name: "Squat", muscleGroup: .quads, secondaryMuscles: [.glutes, .hamstrings], equipment: .bodyweight, difficulty: .beginner,
                     instructions: "Feet shoulder-width, sit back and down, keep chest up."),
            Exercise(name: "Deadlift", muscleGroup: .hamstrings, secondaryMuscles: [.glutes, .back], equipment: .barbell, difficulty: .intermediate,
                     instructions: "Hinge at hips, flat back, drive through heels to stand."),
            Exercise(name: "Overhead Press", muscleGroup: .shoulders, secondaryMuscles: [.triceps], equipment: .dumbbell, difficulty: .intermediate,
                     instructions: "Press dumbbells overhead, biceps by ears at top."),
            Exercise(name: "Bicep Curl", muscleGroup: .biceps, equipment: .dumbbell, difficulty: .beginner,
                     instructions: "Curl dumbbells, squeeze at top, lower slowly."),
            Exercise(name: "Tricep Dip", muscleGroup: .triceps, equipment: .bodyweight, difficulty: .beginner,
                     instructions: "Hands on bench behind you, lower body, press up."),
            Exercise(name: "Plank", muscleGroup: .core, equipment: .bodyweight, difficulty: .beginner,
                     instructions: "Forearms on floor, body straight, hold."),
            Exercise(name: "Lunge", muscleGroup: .quads, secondaryMuscles: [.glutes], equipment: .bodyweight, difficulty: .beginner,
                     instructions: "Step forward, drop back knee, push back to start."),
            Exercise(name: "Kettlebell Swing", muscleGroup: .glutes, secondaryMuscles: [.hamstrings, .core], equipment: .kettlebell, difficulty: .intermediate,
                     instructions: "Hinge, swing bell to chest height using hips."),
        ]
    }
}
