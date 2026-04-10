import SwiftUI

struct ReferenceEntry: Identifiable, Decodable {
	let id: Int
	let title: String
	let body: String
}

struct ContentView: View {
	@State private var entries: [ReferenceEntry] = []
	@State private var isLoading = false
	@State private var errorMessage = ""

	var body: some View {
		NavigationStack {
			Group {
				if isLoading {
					ProgressView("Loading reference data...")
				}
				else if !errorMessage.isEmpty {
					ContentUnavailableView(
						"Could Not Load Data",
						systemImage: "wifi.slash",
						description: Text(errorMessage)
					)
				}
				else {
					List(entries.prefix(12)) { entry in
						NavigationLink(entry.title) {
							ScrollView {
								Text(entry.body)
									frame(maxWidth: .infinity, alignment: .leading)
									.padding()
							}
							.navigationTitle("Detail")
						}
					}
				}
			}
			.navigationTitle("Reference")
			.task {
				await load()
			}
		}
	}

	private func load() async {
		isLoading = true
		errorMessage = ""

		do {
			let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
			let (data, _) = try await URLSession.shared.data(from: url)
			entries = try JSONDecoder().decode([ReferenceEntry].self, from: data)
		}
		catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
	}
}

#Preview {
	ContentView()
}
