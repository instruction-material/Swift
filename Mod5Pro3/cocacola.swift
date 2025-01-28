import SwiftUI

struct cocacola: View {
    var body: some View {
        VStack (spacing:-20) {
            NavigationLink(
                destination: MapView(thelatOne:33.64087555946129,thelongOne:-84.42765718711792,thelatTwo: 33.76277936526282, thelongTwo: -84.39246818901084),
                label: {
                    Text("The World of Coca-Cola")
                        .font(Font.custom("Times New Roman", size: 30))
                        .padding()
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color("lightBlueButton"))
                .padding()
        }
    }
}

struct cocacola_Previews: PreviewProvider {
    static var previews: some View {
        cocacola()
    }
}
