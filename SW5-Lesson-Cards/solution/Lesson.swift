import Foundation

enum LessonStatus {
    case planned
    case active(Double)
    case complete(Date)
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let detail: String?
    var status: LessonStatus

    static let sample = Lesson(id: 7, title: "Map a trail", detail: "Use the north route", status: .planned)
}

func label(for lesson: Lesson) -> String {
    let status: String
    switch lesson.status {
    case .planned: status = "Planned"
    case .active(let fraction): status = "\(Int((fraction * 100).rounded()))%"
    case .complete(let date): status = "Complete \(date.ISO8601Format().prefix(10))"
    }
    let base = "\(lesson.title): \(status)"
    guard let detail = lesson.detail, !detail.isEmpty else { return base }
    return "\(base) | \(detail)"
}
