import SwiftUI

struct Artwork: Identifiable {
	let id = UUID()
	let title: String
	let category: String
	let accent: Color
	let summary: String
}

struct ContentView: View {
	private let artworks = [
		Artwork(title: "Sunset Poster", category: "Photo", accent: .orange, summary: "A warm poster-style sunset composition."),
		Artwork(title: "Studio Desk", category: "Workspace", accent: .blue, summary: "A clean desk setup for editing and sketching."),
		Artwork(title: "Night Walk", category: "Photo", accent: .purple, summary: "City lights and motion blur after dark."),
		Artwork(title: "Sketchbook", category: "Illustration", accent: .pink, summary: "A spread of thumbnail drawings.")
	]

	@State private var selectedCategory = "All"

	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				Picker("Category", selection: $selectedCategory) {
					Text("All").tag("All")
					Text("Photo").tag("Photo")
					Text("Workspace").tag("Workspace")
					Text("Illustration").tag("Illustration")
				}
				.pickerStyle(.segmented)

				ScrollView {
					LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
						ForEach(filteredArtworks) { artwork in
							NavigationLink {
								ArtworkDetailView(artwork: artwork)
							} label: {
								VStack(alignment: .leading, spacing: 10) {
									RoundedRectangle(cornerRadius: 20)
										.fill(artwork.accent.gradient)
										.frame(height: 120)
										.overlay {
											Image(systemName: "photo")
												.font(.system(size: 28))
												.foregroundStyle(.white)
										}

									Text(artwork.title)
										.font(.headline)
										.foregroundStyle(.primary)
									Text(artwork.category)
										.font(.caption)
										.foregroundStyle(.secondary)
								}
							}
						}
					}
				}

				Text("TODO: Add favorites or a stronger detail experience.")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
			.padding()
			.navigationTitle("Gallery")
		}
	}

	private var filteredArtworks: [Artwork] {
		if selectedCategory == "All" {
			return artworks
		}

		// TODO: Replace this quick filter with a reusable approach once the UI grows.
		return artworks.filter { $0.category == selectedCategory }
	}
}

struct ArtworkDetailView: View {
	let artwork: Artwork

	var body: some View {
		VStack(alignment: .leading, spacing: 18) {
			RoundedRectangle(cornerRadius: 28)
				.fill(artwork.accent.gradient)
				.frame(height: 220)
			Text(artwork.title)
				.font(.largeTitle.bold())
			Text(artwork.summary)
				.foregroundStyle(.secondary)
			Spacer()
		}
		.padding()
		.navigationTitle(artwork.title)
	}
}

#Preview {
	ContentView()
}
