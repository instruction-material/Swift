import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let endpoint = URL(string: "https://example.invalid/posts")!

private struct FixedTransport: ReferenceTransport {
    let body: Data
    let response: URLResponse

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        (body, response)
    }
}

private struct CancelledTransport: ReferenceTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.cancelled)
    }
}

private actor RequestProbe: ReferenceTransport {
    private(set) var request: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.request = request
        return try await SampleTransport().data(for: request)
    }
}

private actor ControlledTransport: ReferenceTransport {
    private var count = 0
    private var pending: [Int: CheckedContinuation<(Data, URLResponse), any Error>] = [:]
    private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let id = count
            count += 1
            pending[id] = continuation
            let ready = waiters.filter { $0.0 <= count }
            waiters.removeAll { $0.0 <= count }
            for (_, waiter) in ready { waiter.resume() }
        }
    }

    func waitForRequests(_ expected: Int) async {
        if count >= expected { return }
        await withCheckedContinuation { waiters.append((expected, $0)) }
    }

    func respond(_ id: Int, json: String) {
        let response = HTTPURLResponse(url: endpoint, statusCode: 200,
                                       httpVersion: "HTTP/1.1", headerFields: nil)!
        pending.removeValue(forKey: id)!.resume(returning: (Data(json.utf8), response))
    }
}

private enum ContractFailure: Error {
    case failed(String)
}

@main
private struct ReferenceContracts {
    @MainActor
    static func main() async throws {
        var passed: [String] = []
        func expect(_ value: Bool, _ name: String) throws {
            guard value else { throw ContractFailure.failed(name) }
            passed.append(name)
        }
        func client(_ json: String, status: Int = 200) -> ReferenceClient {
            ReferenceClient(endpoint: endpoint, transport: FixedTransport(
                body: Data(json.utf8), response: HTTPURLResponse(
                    url: endpoint, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!))
        }
        func expectAPIError(_ client: ReferenceClient, _ error: ReferenceAPIError,
                            _ name: String) async throws {
            do {
                _ = try await client.fetch()
                throw ContractFailure.failed(name + ": did not throw")
            } catch let actual as ReferenceAPIError {
                try expect(actual == error, name)
            }
        }

        let sample = try await ReferenceSource.sample.client.fetch()
        try expect(sample.count == 3 && sample[0].id == 1, "offline sample decodes without a network transport")
        let probe = RequestProbe()
        _ = try await ReferenceClient(endpoint: endpoint, transport: probe).fetch()
        let request = await probe.request
        try expect(request?.url == endpoint && request?.httpMethod == "GET", "request uses the supplied endpoint and GET")
        try expect(request?.value(forHTTPHeaderField: "Accept") == "application/json", "request accepts JSON")
        try expect(request?.timeoutInterval == 15, "request has a finite timeout")
        try await expectAPIError(client("not JSON", status: 404), .httpStatus(404), "HTTP404 precedes decoding")
        try await expectAPIError(client("[]", status: 503), .httpStatus(503), "HTTP503 rejects a valid-looking body")
        try await expectAPIError(client("not JSON"), .invalidJSON, "malformed success body fails decoding")
        try await expectAPIError(client("[{\"id\":\"wrong\",\"title\":\"x\",\"body\":\"y\"}]"),
                                 .invalidJSON, "wrong JSON field types fail decoding")
        let empty = try await client("[]").fetch()
        try expect(empty.isEmpty, "empty JSON list is a successful empty result")
        let nonHTTP = ReferenceClient(endpoint: endpoint, transport: FixedTransport(
            body: Data("[]".utf8), response: URLResponse(url: endpoint, mimeType: "application/json",
                                                       expectedContentLength: 2, textEncodingName: nil)))
        try await expectAPIError(nonHTTP, .nonHTTPResponse, "nonHTTP response is rejected")

        guard CommandLine.arguments.count == 2,
              let fixture = URL(string: CommandLine.arguments[1]), fixture.host == "127.0.0.1" else {
            throw ContractFailure.failed("An owned loopback HTTP fixture is required")
        }
        func local(_ path: String) -> ReferenceClient {
            ReferenceClient(endpoint: fixture.appendingPathComponent(path), transport: URLSessionTransport())
        }
        let fetched = try await local("posts").fetch()
        try expect(fetched.first?.title == "Local fixture entry", "real URLSession decodes local HTTP200")
        try await expectAPIError(local("unavailable"), .httpStatus(503), "real URLSession rejects local HTTP503")
        try await expectAPIError(local("malformed"), .invalidJSON, "real URLSession rejects malformed local JSON")
        let localEmpty = try await local("empty").fetch()
        try expect(localEmpty.isEmpty, "real URLSession preserves local empty success")

        let store = ReferenceStore()
        try expect(store.state == .idle, "store begins idle")
        let transport = ControlledTransport()
        let controlled = ReferenceClient(endpoint: endpoint, transport: transport)
        let first = Task { await store.load(client: controlled) }
        await transport.waitForRequests(1)
        try expect(store.state == .loading, "store exposes loading while request is pending")
        await transport.respond(0, json: SampleTransport.json)
        await first.value
        try expect(store.state == .loaded(sample), "store exposes decoded success")
        await store.load(client: client("[]", status: 503))
        try expect(store.state == .failed(ReferenceAPIError.httpStatus(503).localizedDescription),
                   "store exposes a useful HTTP error")
        await store.load(client: ReferenceSource.sample.client)
        try expect(store.state == .loaded(sample), "retry recovers from failure")
        await store.load(client: ReferenceClient(endpoint: endpoint, transport: CancelledTransport()))
        try expect(store.state == .loaded(sample), "URLSession cancellation preserves the settled result")

        let cancelled = Task { await store.load(client: controlled) }
        await transport.waitForRequests(2)
        cancelled.cancel()
        await transport.respond(1, json: "[]")
        await cancelled.value
        try expect(store.state == .loaded(sample), "task cancellation discards a late body and restores settled state")

        let race = ControlledTransport()
        let raceClient = ReferenceClient(endpoint: endpoint, transport: race)
        let old = Task { await store.load(client: raceClient) }
        await race.waitForRequests(1)
        let newer = Task { await store.load(client: raceClient) }
        await race.waitForRequests(2)
        await race.respond(1, json: "[]")
        await newer.value
        try expect(store.state == .loaded([]), "newer response is published first")
        await race.respond(0, json: SampleTransport.json)
        await old.value
        try expect(store.state == .loaded([]), "older response cannot overwrite a newer result")

        let initial = ReferenceStore()
        let initialGate = ControlledTransport()
        let initialClient = ReferenceClient(endpoint: endpoint, transport: initialGate)
        let superseded = Task { await initial.load(client: initialClient) }
        await initialGate.waitForRequests(1)
        let latest = Task { await initial.load(client: initialClient) }
        await initialGate.waitForRequests(2)
        latest.cancel()
        await initialGate.respond(1, json: "[]")
        await latest.value
        try expect(initial.state == .idle, "cancelling overlapping initial loads does not leave loading stuck")
        await initialGate.respond(0, json: SampleTransport.json)
        await superseded.value
        try expect(initial.state == .idle, "superseded initial request remains ignored after cancellation")
        let result: [String: Any] = ["accepted": true, "checks": passed,
                                     "passed": passed.count, "externalRequests": 0,
                                     "realLoopbackHTTP": true]
        print(String(data: try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys]),
                     encoding: .utf8)!)
    }
}
