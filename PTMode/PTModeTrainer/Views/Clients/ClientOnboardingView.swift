import SwiftUI

struct ClientOnboardingView: View {
    let clients: ClientService
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var level: FitnessLevel = .beginner
    @State private var goals = ""
    @State private var injuries = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic info") {
                    TextField("Full name", text: $fullName)
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone).keyboardType(.phonePad)
                }
                Section("Fitness") {
                    Picker("Level", selection: $level) {
                        ForEach(FitnessLevel.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    TextField("Goals (comma separated)", text: $goals)
                    TextField("Injuries / limitations", text: $injuries)
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .navigationTitle("New Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(fullName.isEmpty || email.isEmpty)
                }
            }
        }
    }

    private func save() {
        let trainerID = UUID()
        let user = User(role: .client, fullName: fullName, email: email, phone: phone, trainerID: trainerID)
        let profile = ClientProfile(
            userID: user.id,
            fitnessLevel: level,
            goals: goals.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            injuries: injuries.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            notes: notes
        )
        Task {
            await clients.create(client: user, profile: profile)
            dismiss()
        }
    }
}
