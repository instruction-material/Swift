# SAD4 Map Places App

Connect a supplied list of places to a map camera and matching detail panel.
The starter displays markers and records a selected place, but deliberately
leaves the camera unchanged when a row is selected. Complete models, state and
lists first.

## Run one source role

Use Xcode's iOS App template with SwiftUI and deployment target iOS 17 or later.
Choose `starter/` or `solution/`. Replace the generated App and ContentView
with that role's `MapPlacesApp.swift` and `ContentView.swift`, including both
in the target. Keep one `@main` App and one ContentView. Select an installed
iPhone simulator, build and run. Record Xcode, Swift language mode, deployment
target, simulator model and OS. Keep starter edits separate from the reference.

These fixed, nonpersonal sample coordinates need no device-location permission,
camera, photo library or account. Map tiles can require network access even
though the records are bundled. If tiles are unavailable, record that condition
and check selection/text separately; that is partial evidence rather than a
rendered-map check.

## Read coordinates and camera state

Place groups a name, subtitle and coordinate under one ID.
CLLocationCoordinate2D stores latitude and longitude in degrees. Latitude is
north/south within -90...90; longitude is east/west within -180...180. These
illustrative records are not a live place directory:

| Place | Latitude | Longitude |
| --- | --- | --- |
| Patterson Park | 39.2995 | -76.5848 |
| Neighborhood Cafe | 39.2979 | -76.5907 |
| Harbor Overlook | 39.2850 | -76.6010 |

MKCoordinateRegion holds a center and span. The starter's center is
39.2928, -76.5930 with a 0.05-degree span in each direction. A smaller positive
span shows a closer region. MapCameraPosition.region wraps the region in the
camera type read by Map.

The local cameraPosition is `@State`.
`Map(position: $cameraPosition)` receives a binding so app actions and map
interaction can update that value. Marker reads each place's name/coordinate.
Displaying markers alone does not connect list selection to camera movement.

## Drive the camera and detail from one selection

The starter stores `selectedPlace: Place?`. A list button assigns a place and
opens its basic detail panel. Complete the camera change in that action, or
extract a helper.

The reference stores `selectedPlaceID: Place.ID?` and derives its selected
record using `places.first { $0.id == selectedPlaceID }`. It then updates
both selection and camera:

```swift
private func focus(on place: Place) {
    selectedPlaceID = place.id
    cameraPosition = .region(
        MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.018,
                longitudeDelta: 0.018
            )
        )
    )
}
```

This version requires the reference's selectedPlaceID property and lookup.
When keeping the starter's selectedPlace value, assign
`selectedPlace = place` instead of a nonexistent selectedPlaceID. The
optional represents a valid no-selection state without force-unwrapping.

The reference's marker tint, selected-row symbol and detail read that same
selection. Its onAppear initially focuses the first record. The starter
initially has no selected detail.

Both roles place the map, named selection buttons and detail in one ScrollView.
The vertically stacked buttons grow with the text rather than competing for
height with the fixed map. Scroll to reach every place and the full detail.

## Core project

1. Keep all supplied records and marker names. Make each row selection update
   the camera center and matching detail.
2. Replace the empty visit-note state with fictional place content. If adding
   a detail property, supply it in every initializer.
3. Distinguish the selected place without relying on color alone and retain
   its accessible name.
4. Keep list and detail reachable on a small display at larger text sizes.
   Test scrolling around the fixed-height map.

Pause after selecting a row. Predict the selected value/ID, center, span,
marker and detail title before running.

## Verify

| Action | Expected evidence |
| --- | --- |
| Launch the starter | Three named rows/markers; no detail selected initially |
| Select each row | Center matches its coordinate; its own detail appears |
| Select one row twice | Selection stays valid without duplicate records/markers |
| Pan, then choose another row | Camera returns to the new coordinate and replaces the prior detail |
| Launch the reference | Patterson Park is selected initially |
| Device-location access is unavailable | The fixed-coordinate exercise still needs no location authorization |
| Test small display and larger text | All list rows and detail content remain reachable |

Retain expected/observed results, simulator and tile-network condition.
Optional extensions add a local visit note or map style. Real current-location
support is a separate permission-aware extension with a denied-access path.
