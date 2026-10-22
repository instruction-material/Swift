import SwiftUI

struct ContentView: View {
    @State private var store = ReferenceStore()
    @State private var source: ReferenceSource = .sample
    @State private var query = ""
    @State private var refreshID = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Data source", selection: $source) {
                    ForEach(ReferenceSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                content
            }
            .navigationTitle("Reference")
            .searchable(text: $query, prompt: "Search reference entries")
            .toolbar {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    refreshID += 1
                }
                .disabled(store.state == .loading)
            }
            .task(id: "\(source.id)-\(refreshID)") {
                await store.load(client: source.client)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .idle, .loading:
            ProgressView("Loading reference data…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView {
                Label("Could Not Load Data", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { refreshID += 1 }
            }
        case .loaded(let entries):
            let visible = filtered(entries)
            if entries.isEmpty {
                ContentUnavailableView("No Entries", systemImage: "tray",
                                       description: Text("The service returned an empty list."))
            } else if visible.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(visible) { entry in
                    NavigationLink {
                        ReferenceDetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.title).font(.headline)
                            Text(entry.body).font(.footnote)
                                .foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func filtered(_ entries: [ReferenceEntry]) -> [ReferenceEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return entries }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.body.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

struct ReferenceDetailView: View {
    let entry: ReferenceEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(entry.title).font(.largeTitle.bold())
                Text(entry.body)
                Label("Entry #\(entry.id)", systemImage: "doc.text")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Detail")
    }
}

#Preview {
    ContentView()
}
