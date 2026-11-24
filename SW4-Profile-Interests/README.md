# Profile Interests

## Run the starter

Create an iOS App project in Xcode using SwiftUI and an iOS 17 or later target. Replace the generated app entry point and ContentView with all three Swift files from one role. A site IDE export puts the files under the selected role's folder. Run the app on an installed iPhone simulator.

The starter shows Avery's interests in their original order. Complete a lesson to move the session count from 3 to 4. Switch to Rae with **Show new member**. The count belongs to this session and stays at 4 when the displayed profile changes.

## Core project

1. Display the optional tagline. Show `No tagline yet` for Avery and `Builds robots` for Rae.
2. Add a search field backed by view state. Write a function on Profile that returns names containing the query regardless of case. Sort the results alphabetically. An empty query returns every name. Keep the stored array in its original order.
3. Give a member with no interests the message `No interests yet`. When an existing list has no matches, display `No matches`.

## Check the result

On Avery's profile, an empty search shows Drawing, Music, Robotics. Searching for `O` shows Robotics. Searching for `art` shows No matches. Switch to Rae with that query still entered and check that No interests yet takes precedence. Clear the query and switch back to Avery to recover all three rows.

Explain why a missing tagline, a member with no interests, and a search without matches need three different decisions. Compare the solution after checking the starter changes.
