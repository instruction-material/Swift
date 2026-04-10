import MapKit
import SwiftUI

struct Place: Identifiable {
	let id = UUID()
	let name: String
	let subtitle: String
	let detail: String
	let coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
	private let places = [
		Place(name: "Patterson Park", subtitle: "Outdoor photo walk spot", detail: "A good place for route planning, wide landmarks, and changing light conditions.", coordinate: CLLocationCoordinate2D(latitude: 39.2995, longitude: -76.5848)),
		Place(name: "Neighborhood Cafe", subtitle: "Sketchbook break stop", detail: "Useful for practicing map annotations, category tags, and place metadata.", coordinate: CLLocationCoordinate2D(latitude: 39.2979, longitude: -76.5907)),
		Place(name: "Harbor Overlook", subtitle: "Golden-hour view", detail: "This stop works well for combining a scenic map card with a compact planning note.", coordinate: CLLocationCoordinate2D(latitude: 39.2850, longitude: -76.6010))
	]

	@State private var cameraPosition = MapCameraPosition.region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 39.2928, longitude: -76.5930),
			span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		)
	)

	@State private var selectedPlaceID: Place.ID?

	var body: some View {
		NavigationStack {
			VStack(spacing: 18) {
				Map(position: $cameraPosition) {
					ForEach(places) { place in
						Marker(place.name, coordinate: place.coordinate)
							.tint(selectedPlace?.id == place.id ? .orange : .blue)
					}
				}
				.frame(height: 280)
				.clipShape(RoundedRectangle(cornerRadius: 24))

				List(places) { place in
					Button {
						focus(on: place)
					} label: {
						HStack {
							VStack(alignment: .leading, spacing: 4) {
								Text(place.name)
									.font(.headline)
								Text(place.subtitle)
									.font(.footnote)
									.foregroundStyle(.secondary)
							}

							Spacer()

							if selectedPlace?.id == place.id {
								Image(systemName: "location.fill")
									.foregroundStyle(.orange)
							}
						}
					}
				}
				.listStyle(.plain)

				if let selectedPlace {
					VStack(alignment: .leading, spacing: 10) {
						Text(selectedPlace.name)
							.font(.headline)
						Text(selectedPlace.detail)
							.foregroundStyle(.secondary)
						Label(selectedPlace.subtitle, systemImage: "map")
							.font(.footnote)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
					.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
				}
			}
			.padding()
			.navigationTitle("Places")
			.onAppear {
				if let first = places.first {
					focus(on: first)
				}
			}
		}
	}

	private var selectedPlace: Place? {
		places.first { $0.id == selectedPlaceID }
	}

	private func focus(on place: Place) {
		selectedPlaceID = place.id
		cameraPosition = .region(
			MKCoordinateRegion(
				center: place.coordinate,
				span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
			)
		)
	}
}

#Preview {
	ContentView()
}
