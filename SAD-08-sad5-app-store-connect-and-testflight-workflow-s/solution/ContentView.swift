import SwiftUI

struct ContentView: View {
	@State private var isComplete = false

	var body: some View {
		VStack(spacing: 16) {
			Text("SAD5 App Store Connect and TestFlight Workflow supplemental 2")
			Text(isComplete ? "Ready for extension work." : "Work through the core requirements first.")
			Button("Toggle Status") {
				isComplete.toggle()
			}
		}
		.padding()
	}
}
