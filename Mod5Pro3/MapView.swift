import SwiftUI
import MapKit

struct MapView: UIViewRepresentable  {
    var thelatOne = Double(34.011286)
    var thelongOne = Double(-116.166868)
    var thelatTwo = Double(34.011286)
    var thelongTwo = Double(-116.166868)
    
    typealias UIViewType = MKMapView
      class MapViewCoordinator: NSObject, MKMapViewDelegate {
          func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemPink
            renderer.lineWidth = 5
            return renderer
          }
        }
      func makeCoordinator() -> MapViewCoordinator {
          return MapViewCoordinator()
        }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let region = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74),
          span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)

          let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: thelatOne, longitude: thelongOne))

          let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: thelatTwo, longitude: thelongTwo))
        let request = MKDirections.Request()
          request.source = MKMapItem(placemark: p1)
          request.destination = MKMapItem(placemark: p2)
          request.transportType = .automobile

        let directions = MKDirections(request: request)
          directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            mapView.addAnnotations([p1, p2])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(
              route.polyline.boundingMapRect,
              edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
              animated: true)
          }
          
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}
  }

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
