// Note: Projects only run in Xcode Environment

import SwiftUI

struct ContentView: View {
    var body: some View {
        //the name of my image paris
        Image("paris")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(
                Color.black
                    .opacity(0.4)
                    .overlay(
                        Text("Paris")
                            .font(.custom("Times New Roman", size: 30))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .frame(width: 200)
                    )
            )
    }
}
