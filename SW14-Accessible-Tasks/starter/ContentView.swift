import SwiftUI

struct ContentView: View {
    @State private var complete = false
    @State private var hasTask = true
    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Field journal").font(.title)
                if hasTask {
                    Text("Notes are kept for this session.").font(.caption)
                    Text("Review the trail observations and pack a field notebook")
                        .font(.system(size: 14))
                        .frame(width: 140, height: 18)
                        .lineLimit(1)
                    Circle()
                        .fill(complete ? Color.green : Color.red)
                        .frame(width: 16, height: 16)
                    Button("Change status") { complete.toggle() }
                    Button { saved = true } label: {
                        Image(systemName: "tray.and.arrow.down")
                            .accessibilityHidden(true)
                    }
                    Button("Delete", role: .destructive) { hasTask = false }
                    if saved { Text("Saved") }
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
