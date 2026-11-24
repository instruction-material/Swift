import SwiftUI

struct ContentView: View {
    @State private var tracker = Tracker()
    @State private var draft = ""
    @State private var message = "Enter a task."

    var body: some View {
        NavigationStack {
            List {
                Section("New task") {
                    TextField("Title", text: $draft)
                    Button("Save task") {
                        if tracker.add(draft) {
                            message = "Saved task."
                            draft = ""
                        } else {
                            message = "Enter a title with at least one visible character."
                        }
                    }
                    Text(message)
                }
                Section("Saved tasks: \(tracker.tasks.count)") {
                    ForEach(tracker.tasks) { task in
                        Text(task.title)
                    }
                }
            }
            .navigationTitle("Task tracker")
        }
    }
}
