import SwiftUI

struct aquarium: View {
    var body: some View {
        VStack (spacing:-20) {
            NavigationLink(
                destination: MapView(thelatOne:33.64087555946129,thelongOne:-84.42765718711792,thelatTwo: 33.76355144738556, thelongTwo: -84.39512053134088),
                label: {
                    Text("Georgia Aquarium")
                        .font(Font.custom("Times New Roman", size: 30))
                        .padding()
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color("middleBlueButton"))
                .padding()
        }
    }
}

struct aquarium_Previews: PreviewProvider {
    static var previews: some View {
        aquarium()
    }
}
