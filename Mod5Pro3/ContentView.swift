import MapKit
// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Image("blueBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        Text("Need directions?")
                            .font(Font.custom("Didot", size: 40))
                            .fontWeight(.bold)
                        Museum()
                        Aquarium()
                        CocaCola()
                    }
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
