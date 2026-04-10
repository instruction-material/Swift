import SwiftUI
import UIKit

struct Artwork: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let category: String
	let accent: Color
	let summary: String
	let detail: String
}

struct ContentView: View {
	private let artworks = [
		Artwork(title: "Sunset Poster", category: "Photo", accent: .orange, summary: "A warm poster-style sunset composition.", detail: "Practice big image blocks, text hierarchy, and category tagging."),
		Artwork(title: "Studio Desk", category: "Workspace", accent: .blue, summary: "A clean desk setup for editing and sketching.", detail: "This entry works well for discussing composition and app branding."),
		Artwork(title: "Night Walk", category: "Photo", accent: .purple, summary: "City lights and motion blur after dark.", detail: "Use this card to compare subtle and high-contrast color palettes."),
		Artwork(title: "Sketchbook", category: "Illustration", accent: .pink, summary: "A spread of thumbnail drawings.", detail: "This entry is a good excuse to discuss repeated layouts and reusable cards.")
	]

	@State private var selectedCategory = "All"
	@State private var favorites = Set<UUID>()

	private let categories = ["All", "Photo", "Workspace", "Illustration"]

	var body: some View {
		NavigationStack {
			VStack(spacing: 18) {
				Picker("Category", selection: $selectedCategory) {
					ForEach(categories, id: \.self) { category in
						Text(category).tag(category)
					}
				}
				.pickerStyle(.segmented)

				ScrollView {
					LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
						ForEach(filteredArtworks) { artwork in
							NavigationLink {
								ArtworkDetailView(
									artwork: artwork,
									isFavorite: favorites.contains(artwork.id)
								) {
									toggleFavorite(artwork)
								}
							} label: {
								ArtworkCard(
									artwork: artwork,
									isFavorite: favorites.contains(artwork.id)
								)
							}
							.buttonStyle(.plain)
						}
					}
				}
			}
			.padding()
			.navigationTitle("Gallery")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Text("\(favorites.count) favorites")
						.font(.footnote.bold())
						.foregroundStyle(.secondary)
				}
			}
		}
	}

	private var filteredArtworks: [Artwork] {
		if selectedCategory == "All" {
			return artworks
		}

		return artworks.filter { $0.category == selectedCategory }
	}

	private func toggleFavorite(_ artwork: Artwork) {
		if favorites.contains(artwork.id) {
			favorites.remove(artwork.id)
		}
		else {
			favorites.insert(artwork.id)
		}
	}
}

struct ArtworkCard: View {
	let artwork: Artwork
	let isFavorite: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			RoundedRectangle(cornerRadius: 20)
				.fill(artwork.accent.gradient)
				.frame(height: 126)
				.overlay(alignment: .topTrailing) {
					Image(systemName: isFavorite ? "heart.fill" : "heart")
						.padding(10)
						.foregroundStyle(.white)
				}
				.overlay {
					Image(systemName: "photo.stack")
						.font(.system(size: 28))
						.foregroundStyle(.white)
				}

			Text(artwork.title)
				.font(.headline)
			Text(artwork.summary)
				.font(.footnote)
				.foregroundStyle(.secondary)
			Text(artwork.category)
				.font(.caption.weight(.semibold))
				.foregroundStyle(artwork.accent)
		}
		padding(14)
		.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
	}
}

struct ArtworkDetailView: View {
	let artwork: Artwork
	let isFavorite: Bool
	let onToggleFavorite: () -> Void

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				RoundedRectangle(cornerRadius: 28)
					.fill(artwork.accent.gradient)
					.frame(height: 250)
					.overlay {
						Image(systemName: "photo.artframe")
							.font(.system(size: 52))
							.foregroundStyle(.white)
					}

				Text(artwork.title)
					.font(.largeTitle.bold())
				Text(artwork.detail)
					.foregroundStyle(.secondary)

				Button {
					onToggleFavorite()
				} label: {
					Label(
						isFavorite ? "Remove Favorite" : "Add Favorite",
						systemImage: isFavorite ? "heart.slash" : "heart.fill"
					)
					.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
			}
			.padding()
		}
		.navigationTitle(artwork.title)
	}
}

#Preview {
	ContentView()
}
