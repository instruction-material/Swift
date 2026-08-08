// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    @State private var number = 0

    var body: some View {
        // Display the button view from the tester project file
        tester.ButtonStyleView(number: $number)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ButtonStyleView: View {
    @Binding var number: Int
    private let pictureNames = ["pic1", "pic2", "pic3", "pic4", "pic5"]
    private let descriptions = [
        "First Picture", "Second Picture", "Third Picture", "Fourth Picture",
        "Fifth Picture",
    ]

    var body: some View {
        Button {
            // Return to the first picture after showing the final picture
            if self.number == self.pictureNames.count - 1 {
                self.number = 0
            } else {
                self.number += 1
            }
        } label: {
            VStack {
                Image(pictureNames[self.number])
                    .resizable()
                    .frame(width: 350, height: 450)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                HStack {
                    Text(descriptions[self.number])
                        .font(.system(size: 50, design: .rounded))
                        .foregroundColor(.black)
                    Text("\(self.number)")
                        .font(.system(size: 50, design: .rounded))
                        .foregroundColor(.black)
                }
            }
        }
    }
}
