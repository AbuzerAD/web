import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public final class ProgressService {
    public private(set) var metrics: [BodyMetric] = []
    public private(set) var records: [PersonalRecord] = []
    public private(set) var sessions: [WorkoutSession] = []
    private let backend: BackendService

    public init(backend: BackendService) { self.backend = backend }

    public func load(clientID: UUID, sessionService: SessionService) async {
        do { metrics = try await backend.fetchBodyMetrics(clientID: clientID) } catch { metrics = [] }
        await sessionService.load(clientID: clientID)
        sessions = sessionService.sessions
    }

    public func addMetric(_ m: BodyMetric) async {
        do { try await backend.saveBodyMetric(m) } catch {}
        metrics.append(m)
        metrics.sort { $0.recordedAt < $1.recordedAt }
    }

    public func addRecord(_ r: PersonalRecord) async {
        do { try await backend.savePersonalRecord(r) } catch {}
        records.append(r)
    }
}
