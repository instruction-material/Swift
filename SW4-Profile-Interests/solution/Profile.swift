struct Profile {
    let name: String
    let tagline: String?
    let interests: [String]

    static let sample = Profile(name: "Avery", tagline: nil, interests: ["Drawing", "Robotics", "Music"])
    static let newMember = Profile(name: "Rae", tagline: "Builds robots", interests: [])

    func matchingInterests(_ query: String) -> [String] {
        interests.filter { query.isEmpty || $0.lowercased().contains(query.lowercased()) }.sorted()
    }
}
