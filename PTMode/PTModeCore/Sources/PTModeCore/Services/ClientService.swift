import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public final class ClientService {
    public private(set) var clients: [User] = []
    public private(set) var profiles: [UUID: ClientProfile] = [:]
    private let backend: BackendService

    public init(backend: BackendService) { self.backend = backend }

    public func load(trainerID: UUID) async {
        do { clients = try await backend.fetchClients(trainerID: trainerID) } catch { clients = [] }
    }

    public func create(client: User, profile: ClientProfile) async {
        clients.append(client)
        profiles[client.id] = profile
        do { try await backend.createClient(client, profile: profile) } catch {}
    }

    public func profile(for clientID: UUID) -> ClientProfile? { profiles[clientID] }

    public func updateProfile(_ profile: ClientProfile) async {
        profiles[profile.userID] = profile
        do { try await backend.updateClientProfile(profile) } catch {}
    }
}

@MainActor
@Observable
public final class SessionService {
    public private(set) var sessions: [WorkoutSession] = []
    private let backend: BackendService

    public init(backend: BackendService) { self.backend = backend }

    public func load(clientID: UUID) async {
        do { sessions = try await backend.fetchSessions(clientID: clientID) } catch { sessions = [] }
    }

    public func save(_ session: WorkoutSession) async {
        if let i = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[i] = session
        } else {
            sessions.append(session)
        }
        do { try await backend.saveSession(session) } catch {}
    }
}
