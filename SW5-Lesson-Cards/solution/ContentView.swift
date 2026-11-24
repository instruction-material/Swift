import SwiftUI

struct ContentView: View {
    @State private var lesson = Lesson.sample

    var body: some View {
        List {
            Section("Lesson") {
                Text(label(for: lesson))
                Text("ID: \(lesson.id)")
            }
            Section("Update status") {
                Button("Plan again") { lesson.status = .planned }
                Button("Begin lesson") { lesson.status = .active(0) }
                Button("Halfway") { lesson.status = .active(0.5) }
                Button("Full progress") { lesson.status = .active(1) }
                Button("Record sample completion") {
                    lesson.status = .complete(Date(timeIntervalSince1970: 1_767_225_600))
                }
            }
        }
    }
}
