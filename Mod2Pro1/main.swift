// Note: Projects only run in Xcode Environment

import SwiftUI

struct ContentView: View {
    var body: some View{
        NavigationView(){
             NavigationLink(destination:one()){
                Text("About Me")
                    .font(.largeTitle)
                    .foregroundColor(Color.purple)
              }
        }
     }
}

