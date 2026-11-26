import Foundation
import SwiftUI
import Observation

/// Holds the currently signed-in user and drives auth state for both apps.
@MainActor
@Observable
public final class AuthService {
    public private(set) var currentUser: User?
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let backend: BackendService

    public init(backend: BackendService = MockBackendService()) {
        self.backend = backend
    }

    public var isSignedIn: Bool { currentUser != nil }
    public var isTrainer: Bool { currentUser?.role == .trainer }
    public var isClient: Bool { currentUser?.role == .client }

    public func signIn(email: String, password: String) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            currentUser = try await backend.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func signUp(email: String, password: String, role: UserRole, fullName: String) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            currentUser = try await backend.signUp(email: email, password: password, role: role, fullName: fullName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func signOut() async {
        try? await backend.signOut()
        currentUser = nil
    }
}
