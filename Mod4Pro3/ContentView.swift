// Note: Projects only run in Xcode Environment
​​import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ZStack{
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 150)
                    .offset(x: 0, y: -175)
                Ellipse()
                    .foregroundColor(.blue)
                    .frame(width: 70, height: 30)
                    .offset(x: 0, y: -95)
                Ellipse()
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 200)
                    .offset(x: 0, y: 10)
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 200)
                    .offset(x: -60, y: 50)
                    .rotationEffect(.degrees(60))
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 200)
                    .offset(x: -60, y: -60)
                    .rotationEffect(.degrees(120))
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 200)
                    .offset(x: 45, y: 150)
                    .rotationEffect(.degrees(15))
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 200)
                    .offset(x: -40, y: 150)
                    .rotationEffect(.degrees(340))
                Ellipse()
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 15)
                    .offset(x: -5, y: 250)
                Ellipse()
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 15)
                    .offset(x: 65, y: 250)
            }
            ZStack{
                Circle()
                    .foregroundColor(.yellow)
                    .frame(width: 35, height: 35)
                    .offset(x: 25, y: -175)
                Circle()
                    .foregroundColor(.yellow)
                    .frame(width: 35, height: 35)
                    .offset(x: -25, y: -175)
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 10, height: 10)
                    .offset(x: -25, y: -175)
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 10, height: 10)
                    .offset(x: 25, y: -175)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
