import SwiftUI

struct HobbyCard: View {
    let hobby: Hobby

    var body: some View {
        VStack(alignment: .leading) {
            Text(hobby.name).font(.headline)
            Text("Bring: \(hobby.supply)")
        }
    }
}
