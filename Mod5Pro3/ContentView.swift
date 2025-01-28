// Note: Projects only run in Xcode Environment
​​import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            Image("blueBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack{
                        Text("Need directions?")
                            .font(Font.custom("Didot", size: 40))
                            .fontWeight(.bold)
                        museum()
                        aquarium()
                        cocacola()
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
