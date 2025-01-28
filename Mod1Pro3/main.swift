// Note: Projects only run in Xcode Environment

import SwiftUI

struct ContentView: View {
    var body: some View{
        NavigationView(){
             NavigationLink(destination:one()){
                Text("Hello World")
                    .font(.largeTitle)
                    .foregroundColor(Color.purple)
              }
        }
     }
}

