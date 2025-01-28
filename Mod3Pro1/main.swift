// Note: Projects only run in Xcode Environment
import SwiftUI

struct ContentView: View {
    @State private var Numb = 0
    
    var body: some View {
        tester.buttonStyle(Numb: $Numb)
        // tester is the name of the project file
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct buttonStyle: View {
    @Binding var Numb: Int
    var picture = ["pic1", "pic2", "pic3", "pic4", "pic5"]
    let description = ["First Picture", "Second Picture", "Third Picture","Fourth Picture", "Fifth Picture"]
    var body: some View {
        Button (action: {
            if(self.Numb == 4){
                self.Numb = 0
            } else {
                self.Numb += 1
            }
            
        }) {
            VStack{
                Image(picture[self.Numb])
                    .resizable()
                    .frame(width: 350, height: 450)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                HStack{
                    Text(description[self.Numb])
                        .font(.system(size: 50, design: .rounded))
                        .foregroundColor(.black)
                    Text("\(self.Numb)")
                        .font(.system(size: 50, design: .rounded))
                        .foregroundColor(.black)
                }
                    
            }
        }
        
    }
}
