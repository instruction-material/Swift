import SwiftUI

struct ContentView: View {
	@State private var isComplete = false

	var body: some View {
		VStack(spacing: 16) {
			Text("SAD15 Networking and Data Loading supplemental 3")
			Text(isComplete ? "Ready for extension work." : "Work through the core requirements first.")
			Button("Toggle Status") {
				isComplete.toggle()
			}
		}
		.padding()
	}
}
