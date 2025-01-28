// Note: Projects only run in Xcode Environment
​​import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("See the White House!")
                    .font(.title)
                    .fontWeight(.bold)
                whiteHouse()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct whiteHouse: View {
    var body: some View {
        VStack (spacing:-20){
            NavigationLink(
                destination: MapView(thelat: 38.897818228008646,thelong: -77.03650834471178, pickMap: 0, whichMap: [MKMapType.standard], mapType: MKMapType.standard),
                label: {
                    Text("White House Standard Map")
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color.blue)
                .padding()
            
            NavigationLink(
                destination: MapView(thelat: 38.897818228008646,thelong: -77.03650834471178, pickMap: 0, whichMap: [MKMapType.satellite], mapType: MKMapType.satellite),
                label: {
                    Text("White House Satellite Map")
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color.blue)
                .padding()
            NavigationLink(
                destination: MapView(thelat: 38.897818228008646,thelong: -77.03650834471178, pickMap: 0, whichMap: [MKMapType.hybrid], mapType: MKMapType.hybrid),
                label: {
                    Text("White House Satellite Flyover Map")
                })
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black)
                .background(Color.blue)
                .padding()
            
        }
    }
}
