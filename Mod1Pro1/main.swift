// Note: Projects only run in Xcode Environment

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World!")
            .fontWeight(.bold)
            .font(.title)
            .padding()
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .lineSpacing(10)
    
    //extra features that can be discussed about but not necessary
            .rotation3DEffect(
                .degrees(60),
                axis: (x: 1, y: 0, z: 0))
            .shadow(color: .gray, radius: 2, x: 0, y: 10)
    }
}
