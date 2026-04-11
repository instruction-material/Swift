import SwiftUI

struct ContentView: View {
	@State private var isComplete = false

	var body: some View {
		VStack(spacing: 16) {
			Text("SAD4 Running on Simulator and Device supplemental 3")
			Text(isComplete ? "Ready for extension work." : "Work through the core requirements first.")
			Button("Toggle Status") {
				isComplete.toggle()
			}
		}
		.padding()
	}
}
