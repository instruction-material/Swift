import SwiftUI

struct ProfileHeader: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "paperplane.fill")
                .foregroundStyle(Color("ProfileAccent"))
                .accessibilityHidden(true)
            Text(title)
                .font(.title)
                .accessibilityIdentifier("launch-title")
            Text("Flight journal")
                .font(.subheadline)
        }
    }
}
