import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct ReferenceEntry: Identifiable, Decodable, Equatable, Sendable {
    let id: Int
    let title: String
    let body: String
}

protocol ReferenceTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionTransport: ReferenceTransport {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

enum ReferenceAPIError: Error, Equatable, LocalizedError {
    case nonHTTPResponse
    case httpStatus(Int)
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .nonHTTPResponse:
            return "The service did not return an HTTP response."
        case .httpStatus(let status):
            return "The service returned HTTP \(status). Try again later."
        case .invalidJSON:
            return "The response did not contain valid reference entries."
        }
    }
}

struct ReferenceClient: Sendable {
    let endpoint: URL
    let transport: any ReferenceTransport

    func fetch() async throws -> [ReferenceEntry] {
        try Task.checkCancellation()
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await transport.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse else {
            throw ReferenceAPIError.nonHTTPResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ReferenceAPIError.httpStatus(http.statusCode)
        }
        do {
            return try JSONDecoder().decode([ReferenceEntry].self, from: data)
        } catch {
            throw ReferenceAPIError.invalidJSON
        }
    }
}

enum ReferenceSource: String, CaseIterable, Identifiable {
    case sample = "Sample data"
    case live = "Live data"

    var id: Self { self }

    var client: ReferenceClient {
        let endpoint = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        switch self {
        case .sample:
            return ReferenceClient(endpoint: endpoint, transport: SampleTransport())
        case .live:
            return ReferenceClient(endpoint: endpoint, transport: URLSessionTransport())
        }
    }
}

struct SampleTransport: ReferenceTransport {
    static let json = """
    [
      {"id": 1, "title": "Sketch a readable screen", "body": "Group related information and keep one clear title."},
      {"id": 2, "title": "Check an HTTP response", "body": "Validate the status before decoding the response body."},
      {"id": 3, "title": "Keep state predictable", "body": "A cancelled request must not replace a newer result."}
    ]
    """

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try Task.checkCancellation()
        let response = HTTPURLResponse(url: request.url!, statusCode: 200,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: ["Content-Type": "application/json"])!
        return (Data(Self.json.utf8), response)
    }
}
