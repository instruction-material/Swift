# Trace and refactor HobbyMap

Open the exported role’s HobbyMap.xcodeproj in Xcode. Choose the HobbyMap scheme and an installed iPhone simulator with iOS 17 or later. The app lists Sketching and Hiking. Select Hiking and check that the card says “Bring: Water bottle.” Go back, open Sketching and check for “Bring: Pencil.”

## Follow the startup path

HobbyMapApp is the single @main entry point. Its WindowGroup supplies ContentView. The root view builds a NavigationStack and a List from SampleData.hobbies. Selecting a row creates a HobbyCard with that row’s Hobby value. Each hobby has a stable string ID, a name and a supply. The card reads a value; navigation selects which value it receives.

In the starter, the declarations for Hobby, SampleData and HobbyCard all sit in ContentView.swift. The three matching destination files are already part of the app target. The reference has exactly the same two records and actions with the declarations separated.

## Move one responsibility at a time

Move Hobby into Hobby.swift and SampleData into SampleData.swift. Move HobbyCard into HobbyCard.swift and import SwiftUI there. Remove each original declaration as it moves; leaving two copies gives a duplicate-type error. Keep the app entry point and NavigationStack in their existing files. Build after each move so a failure identifies one small change.

Change Hiking’s supply to “Rain jacket” in the sample data. Predict which detail changes and which stays the same. Run both paths. Restore the original fixture before using Product > Test; the supplied UI test checks both original supply labels. A refactor preserves those observations while changing where each responsibility lives.

## Check the result

Draw the path from launch to the Hiking card. Mark the file that owns the record and the file that only displays it. Returning from the card changes the navigation state. It leaves the bundled sample data intact. Compare the starter and reference to explain why the entry point stays stable when a card’s layout changes.
