import SwiftUI
import MapKit

struct MapView: UIViewRepresentable  {
    var thelat = Double(34.011286)
    var thelong = Double(-116.166868)
    var pickMap = 0
    var whichMap = [MKMapType.hybrid, MKMapType.satellite, MKMapType.standard]
    var mapType = MKMapType.hybrid
    func makeUIView(context: Context) -> MKMapView {
           MKMapView(frame: .zero)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(
            latitude: thelat, longitude: thelong)
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
        uiView.mapType = whichMap[pickMap]
    }
    
    }


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(thelat: 34.011286, thelong: -116.166868)
    }
}
