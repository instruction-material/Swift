import SwiftUI

struct ShapeSlice: Identifiable {
	let id = UUID()
	let label: String
	let value: Double
	let color: Color
}

struct ContentView: View {
	let slices = [
		ShapeSlice(label: "Build", value: 0.45, color: .orange),
		ShapeSlice(label: "Test", value: 0.30, color: .teal),
		ShapeSlice(label: "Share", value: 0.25, color: .purple)
	]

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 28) {
					Text("SwiftUI Shapes Studio")
						.font(.largeTitle.bold())

					Text("Use this optional pack to practice basic shapes, arcs, and layered shape composition.")
						.foregroundStyle(.secondary)

					GroupBox("Classic Shape Stack") {
						VStack(spacing: 20) {
							Circle()
								.fill(.blue)
								.frame(width: 120, height: 120)

							// TODO: add an ellipse and a rectangle below the circle
							// and make the full stack feel like one composed object.
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 12)
					}

					GroupBox("Arc and Pie Practice") {
						VStack(alignment: .leading, spacing: 16) {
							ZStack {
								Circle()
									.stroke(.gray.opacity(0.2), lineWidth: 28)
									.frame(width: 220, height: 220)

								// TODO: replace this placeholder circle with arc-based slices
								// built from Path so the chart reflects the values in slices.
								Circle()
									.fill(.purple.opacity(0.25))
									.frame(width: 120, height: 120)
							}

							ForEach(slices) { slice in
								HStack {
									Circle()
										.fill(slice.color)
										.frame(width: 12, height: 12)
									Text(slice.label)
									Spacer()
									Text("\(Int(slice.value * 100))%")
										.foregroundStyle(.secondary)
								}
							}
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 12)
					}

					GroupBox("Build a Creature") {
						ZStack {
							Ellipse()
								.fill(.mint.opacity(0.35))
								.frame(width: 220, height: 150)

							Circle()
								.fill(.white)
								.frame(width: 40, height: 40)
								.offset(x: -40, y: -20)
							Circle()
								.fill(.white)
								.frame(width: 40, height: 40)
								.offset(x: 40, y: -20)

							// TODO: add pupils, a mouth, and two more body parts using
							// only SwiftUI shapes and transforms.
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 18)
					}
				}
				.padding(24)
			}
			.navigationTitle("Optional Enrichment")
		}
	}
}
