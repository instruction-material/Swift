import SwiftUI

struct ShapeSlice: Identifiable {
	let id = UUID()
	let label: String
	let value: Double
	let color: Color
}

struct PieSliceView: Shape {
	let start: Double
	let end: Double

	func path(in rect: CGRect) -> Path {
		var path = Path()
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let radius = min(rect.width, rect.height) / 2

		path.move(to: center)
		path.addArc(
			center: center,
			radius: radius,
			startAngle: .degrees(start - 90),
			endAngle: .degrees(end - 90),
			clockwise: false
		)
		path.closeSubpath()
		return path
	}
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

					Text("A creative optional pack for circles, rectangles, ellipses, arcs, and layered shape composition.")
						.foregroundStyle(.secondary)

					GroupBox("Classic Shape Stack") {
						VStack(spacing: 12) {
							Circle()
								.fill(.blue.gradient)
								.frame(width: 120, height: 120)
								shadow(color: .blue.opacity(0.25), radius: 10, y: 8)

							Ellipse()
								.fill(.pink.gradient)
								.frame(width: 84, height: 34)

							Rectangle()
								.fill(.yellow.gradient)
								.frame(width: 28, height: 170)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(.yellow.opacity(0.45), lineWidth: 2)
								)
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 12)
					}

					GroupBox("Arc and Pie Practice") {
						VStack(alignment: .leading, spacing: 16) {
							ZStack {
								ForEach(Array(slices.enumerated()), id: \.offset) { _, slice in
									let range = angleRange(for: slice)
									PieSliceView(start: range.start, end: range.end)
										.fill(slice.color.gradient)
										.overlay(
											PieSliceView(start: range.start, end: range.end)
												.stroke(.white.opacity(0.8), lineWidth: 3)
										)
								}

								Circle()
									.fill(.background)
									.frame(width: 86, height: 86)
									overlay(
										Text("AD4")
											.font(.headline.weight(.semibold))
									)
							}
							.frame(width: 220, height: 220)
							.frame(maxWidth: .infinity)

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
								.fill(.mint.gradient)
								.frame(width: 230, height: 150)

							Circle()
								.fill(.mint)
								.frame(width: 140, height: 140)
								.offset(y: -55)

							Rectangle()
								.fill(.mint)
								.frame(width: 24, height: 150)
								rotationEffect(.degrees(25))
								.offset(x: -78, y: 54)
							Rectangle()
								.fill(.mint)
								.frame(width: 24, height: 150)
								rotationEffect(.degrees(-25))
								.offset(x: 78, y: 54)

							Circle()
								.fill(.white)
								.frame(width: 42, height: 42)
								.offset(x: -42, y: -72)
							Circle()
								.fill(.white)
								.frame(width: 42, height: 42)
								.offset(x: 42, y: -72)
							Circle()
								.fill(.black)
								.frame(width: 10, height: 10)
								.offset(x: -42, y: -72)
							Circle()
								.fill(.black)
								.frame(width: 10, height: 10)
								.offset(x: 42, y: -72)

							Capsule()
								.fill(.black.opacity(0.8))
								.frame(width: 82, height: 12)
								.offset(y: -18)

							Ellipse()
								.fill(.mint.opacity(0.9))
								.frame(width: 58, height: 14)
								.offset(x: -30, y: 118)
							Ellipse()
								.fill(.mint.opacity(0.9))
								.frame(width: 58, height: 14)
								.offset(x: 30, y: 118)
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

	private func angleRange(for target: ShapeSlice) -> (start: Double, end: Double) {
		var current = 0.0
		for slice in slices {
			let next = current + slice.value * 360
			if slice.id == target.id {
				return (current, next)
			}
			current = next
		}
		return (0, 0)
	}
}
