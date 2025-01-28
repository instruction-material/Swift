import SwiftUI

struct museum: View {
    var body: some View {
        VStack (spacing:-20) {
            NavigationLink(
                destination: MapView(thelatOne:33.64087555946129,thelongOne:-84.42765718711792,thelatTwo: 33.79019692854225, thelongTwo: -84.38554127367028),
                label: {
                    Text("High Museum of Art")
                        .font(Font.custom("Times New Roman", size: 30))
                        .padding()
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color("darkBlueButton"))
                .padding()
        }
    }
}

struct museum_Previews: PreviewProvider {
    static var previews: some View {
        museum()
    }
}
