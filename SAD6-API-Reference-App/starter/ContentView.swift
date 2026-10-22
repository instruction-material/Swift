import SwiftUI

struct ContentView: View {
    @State private var store = ReferenceStore()
    @State private var refreshID = 0

    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .idle, .loading:
                    ProgressView("Loading reference data…")
                case .failed(let message):
                    ContentUnavailableView("Could Not Load Data", systemImage: "wifi.slash",
                                           description: Text(message))
                case .loaded(let entries):
                    List(entries) { entry in
                        NavigationLink(entry.title) {
                            ScrollView {
                                Text(entry.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .navigationTitle("Detail")
                        }
                    }
                }
            }
            .navigationTitle("Reference")
            .toolbar {
                Button("Refresh") { refreshID += 1 }
                    .disabled(store.state == .loading)
            }
            .task(id: refreshID) {
                await store.load(client: ReferenceSource.sample.client)
            }
        }
    }
}

#Preview {
    ContentView()
}
