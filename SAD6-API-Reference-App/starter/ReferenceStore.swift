import Foundation
import Observation

enum ReferenceLoadState: Equatable {
    case idle
    case loading
    case loaded([ReferenceEntry])
    case failed(String)
}

@MainActor
@Observable
final class ReferenceStore {
    private(set) var state: ReferenceLoadState = .idle
    private var requestID = UUID()
    private var lastSettledState: ReferenceLoadState = .idle

    func load(client: ReferenceClient) async {
        let current = UUID()
        requestID = current
        state = .loading
        do {
            let entries = try await client.fetch()
            try Task.checkCancellation()
            settle(.loaded(entries), request: current)
        } catch is CancellationError {
            restoreAfterCancellation(request: current)
        } catch let error as URLError where error.code == .cancelled {
            restoreAfterCancellation(request: current)
        } catch let error as ReferenceAPIError {
            settle(.failed(error.localizedDescription), request: current)
        } catch {
            settle(.failed("Could not reach the service. Check the connection and try again."),
                   request: current)
        }
    }

    private func settle(_ result: ReferenceLoadState, request: UUID) {
        guard requestID == request else { return }
        state = result
        lastSettledState = result
    }

    private func restoreAfterCancellation(request: UUID) {
        guard requestID == request else { return }
        state = lastSettledState
    }
}
