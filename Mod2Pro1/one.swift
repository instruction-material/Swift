import SwiftUI

struct one: View {
    var body: some View {
        VStack{
            Image("selfie")
                .resizable()
                   .aspectRatio(contentMode: .fit)
            Text("Alfie the Dog")
                .font(.largeTitle)
                .foregroundColor(Color.purple)
            Text("Hi, my name is Alfie. I am a golden retriever and I like to play tug of war with my siblings.")
                .font(.system(size: 20, weight: .light, design: .serif))
                .foregroundColor(Color.purple)
            }
    }
}
