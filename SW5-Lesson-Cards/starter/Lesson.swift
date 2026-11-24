struct Lesson: Identifiable {
    let id: Int
    let title: String
    let detail: String?
    var statusText: String

    static let sample = Lesson(id: 7, title: "Map a trail", detail: "Use the north route", statusText: "Planned")
}
