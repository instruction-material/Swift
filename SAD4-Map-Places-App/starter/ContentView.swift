import MapKit
import SwiftUI

struct Place: Identifiable {
	let id = UUID()
	let name: String
	let subtitle: String
	let coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
	private let places = [
		Place(name: "Patterson Park", subtitle: "Outdoor photo walk spot", coordinate: CLLocationCoordinate2D(latitude: 39.2995, longitude: -76.5848)),
		Place(name: "Neighborhood Cafe", subtitle: "Sketchbook break stop", coordinate: CLLocationCoordinate2D(latitude: 39.2979, longitude: -76.5907)),
		Place(name: "Harbor Overlook", subtitle: "Golden-hour view", coordinate: CLLocationCoordinate2D(latitude: 39.2850, longitude: -76.6010))
	]

	@State private var cameraPosition = MapCameraPosition.region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 39.2928, longitude: -76.5930),
			span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		)
	)

	@State private var selectedPlace: Place?

	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				Map(position: $cameraPosition) {
					ForEach(places) { place in
						Marker(place.name, coordinate: place.coordinate)
					}
				}
				.frame(height: 260)
				.clipShape(RoundedRectangle(cornerRadius: 24))

				List(places) { place in
					Button {
						selectedPlace = place
						// TODO: Move the map camera to the selected place.
					} label: {
						VStack(alignment: .leading) {
							Text(place.name)
							Text(place.subtitle)
								.font(.footnote)
								.foregroundStyle(.secondary)
						}
					}
				}
				.listStyle(.plain)

				if let selectedPlace {
					VStack(alignment: .leading, spacing: 8) {
						Text(selectedPlace.name)
							.font(.headline)
						Text(selectedPlace.subtitle)
							.foregroundStyle(.secondary)
						Text("TODO: Add a stronger detail card with visit notes and a callout style.")
							.font(.footnote)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
					.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
				}
			}
			.padding()
			.navigationTitle("Places")
		}
	}
}

#Preview {
	ContentView()
}
