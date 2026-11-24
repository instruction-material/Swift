import SwiftUI

struct ContentView: View {
    @State private var complete = false
    @State private var hasTask = true
    @State private var saved = false
    @State private var confirmRemoval = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Field journal").font(.title)
                if hasTask {
                    Text("Review the trail observations and pack a field notebook")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Toggle("Completed", isOn: $complete)
                    Text(complete ? "Status: complete" : "Status: open")
                    Button("Save task", systemImage: "tray.and.arrow.down") { saved = true }
                    Button("Delete task", role: .destructive) { confirmRemoval = true }
                        .alert("Delete this task?", isPresented: $confirmRemoval) {
                            Button("Confirm deletion", role: .destructive) { hasTask = false }
                            Button("Cancel", role: .cancel) {}
                        }
                    if saved { Text("Saved") }
                    Text("Notes are kept for this session.").font(.footnote)
                } else {
                    Text("No tasks")
                    Button("Restore sample") {
                        hasTask = true
                        complete = false
                        saved = false
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
