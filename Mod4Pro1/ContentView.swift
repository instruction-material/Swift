// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
               Circle()
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 150)
                    .offset(x: 0, y: -150)
                Ellipse()
                    .foregroundColor(.pink)
                    .frame(width: 70, height: 30)
                    .offset(x: 0, y: 0)
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: 25, height: 200)
                    .offset(x: 0, y: 150)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
