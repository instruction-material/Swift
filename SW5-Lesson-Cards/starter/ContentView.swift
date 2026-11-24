import SwiftUI

struct ContentView: View {
    @State private var lesson = Lesson.sample

    var body: some View {
        List {
            Text(lesson.title)
            Text(lesson.statusText)
            Button("Begin lesson") { lesson.statusText = "0%" }
            // Add halfway, full progress, and dated completion actions.
        }
    }
}
