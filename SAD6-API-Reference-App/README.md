# SAD6 API Reference App

This is the core reference app for SW12 Networking and Data Loading. It uses
Swift 6, SwiftUI and an iOS 17-or-later deployment target. The app reads a list
of reference entries, searches it and opens an entry's detail screen.

## Source and first run

Create an iOS App project in Xcode using SwiftUI. Select one role and add all
four Swift files from that role to the app target: `APIReferenceApp.swift`,
`ContentView.swift`, `ReferenceClient.swift` and `ReferenceStore.swift`. Replace
the generated app entry point and content view; keep one `@main` entry point.
Select an installed simulator, build and run.

A single-role copy keeps that role's four Swift files, this `README.md`,
`verify-networking.py` and `tests/ReferenceContracts.swift`, preserving their
folder names. Add only the selected role's app files to the Xcode target;
`tests/ReferenceContracts.swift` is a separate command-line test entry point.
Do not add that test entry point to the app target.

Both roles start with three local sample entries. Sample mode passes embedded
JSON through the same status-checking and decoding code as the live route,
without opening a network connection. The reference also offers **Live data**,
which reads the public JSONPlaceholder `/posts` endpoint. No key or account is
required. Live data depends on that service and the connection; sample data
remains available when either is unavailable.

The starter provides a working list, detail navigation, refresh and the tested
networking/state layers. The core work completes the source selector, search,
empty states and presentation described below. The reference demonstrates the
completed behavior. The two roles use identical client and store files.

## Follow one request

1. `ContentView` owns a `ReferenceStore` in `@State`. The store is observable,
   so assigning a new `state` causes the relevant SwiftUI view to update.
2. The view's `.task(id:)` calls `store.load`. A changed data source or refresh
   identifier creates a new task. SwiftUI cancels the previous view task when
   its identifier changes or the view disappears.
3. `ReferenceClient` makes a GET request with an `Accept: application/json`
   header and a finite timeout. A `ReferenceTransport` supplies bytes and a
   response. The sample transport supplies local data; `URLSessionTransport`
   performs the actual request.
4. The client first requires an HTTP response, then a status from 200 through
   299. Only a successful response reaches `JSONDecoder`.
5. The decoder maps the JSON list into `[ReferenceEntry]`. Each entry needs an
   integer `id` and string `title` and `body` values. Extra fields such as
   JSONPlaceholder's `userId` are ignored. A missing required field, wrong type,
   malformed document or object in place of a list is a decoding failure.
6. The store publishes loaded entries or a useful failure message on the main
   actor. The view selects the corresponding loading, list, empty or error UI.

For example, this document decodes as one entry:

```json
[{"id": 42, "title": "Local fixture entry", "body": "Owned HTTP fixture."}]
```

Receiving bytes does not establish success. A service can return HTTP 503 with
the perfectly valid JSON body `[]`. Decoding that body first would incorrectly
show an empty success screen. The status guard rejects it as a server failure.
Conversely, HTTP 200 with `[]` is a successful empty result and needs an empty
state, not an error message. A successful status with malformed JSON is a
different failure at the decoding boundary.

## Loading, cancellation and request order

`ReferenceLoadState` represents one visible state at a time: idle, loading,
loaded entries or a failure message. This avoids combinations such as showing
an old error and a successful list simultaneously. `@MainActor` keeps the
observable state mutations on the UI actor. An `await` suspends the operation
while transport work is pending; it does not make the UI wait synchronously.

Cancellation is an expected lifecycle event. It restores the last settled
state instead of displaying a connection error. The client checks cancellation
before and after transport, so even a transport that returns late cannot make
a cancelled operation publish its data.

Cancellation alone does not settle request order. The store gives each load a
new identifier and accepts a result only if it still belongs to the latest
load. If request A starts, request B starts, B finishes, and A finishes last,
B's result remains visible. The same rule stops a cancelled old task from
restoring state over a newer request. The saved settled state also prevents a
cancelled pair of initial loads from leaving the app stuck on a spinner.

## Core project

1. Run the starter with sample data. Trace the path from `.task` through the
   store, client and transport, then back to the list. Locate the HTTP and JSON
   checks before changing the view.
2. Add a source selector using `ReferenceSource.allCases`. Include the selected
   source and refresh identifier in the task identity. Selecting live data must
   use `URLSessionTransport`; returning to sample data must work offline.
3. Add search over both entry titles and bodies. Trim surrounding whitespace
   and compare without case sensitivity. Keep the original entries intact so
   clearing the query restores the full result.
4. Distinguish an empty service result from a nonempty result with no search
   matches. Keep a visible retry action in the failure state.
5. Give the detail screen a clear entry title, body and entry identifier. Keep
   the text readable on a small screen and at larger text sizes.

Completion means all three sample entries load; searching for `HTTP` finds the
status-check entry; a query with no matches shows a search empty state; clearing
the query restores all entries; and a detail screen returns to the same list.
Switching data sources during a pending request must not display a stale result
from the previous source. Refresh and retry must recover without restarting the
app.

## Check the contracts

From this pack's directory, run:

```sh
python3 verify-networking.py
```

The verifier uses the source roles present in the copy. With both roles, it
also checks that their client and store implementations match. A single-role
copy checks its own client and store without needing the other role; missing
app files still fail verification.

The command requires the installed Swift 6 toolchain and Python 3. It compiles
the supplied client, store and contract checks, starts an owned HTTP fixture on
loopback, then closes the server and removes its temporary build files. It
does not call the public API or install packages. `--proof /path/to/new.json`
retains the results and process records; use a new path for each attempt.

The checks cover HTTP status validation before decoding, malformed and
wrong-shaped JSON, empty success, actual `URLSession` requests to local HTTP
responses, loading and retry, cancellation, and requests completing in reverse
order. The controlled request checks use continuations to choose completion
order instead of depending on timing or a public outage.

These checks verify the client and store contract. Build the selected role in Xcode
and verify the source selector, search, detail navigation, retry, small-screen
layout and larger text separately; a client test cannot prove view behavior.

For an instructor walkthrough, pause before the status guard, before decoding
and before publishing state. Predict which visible state follows HTTP 503 with
`[]`, HTTP 200 with `[]`, malformed JSON, cancellation and a late old response,
then run the matching checks.

## Choice and challenge work

- **Choice: filtered reference.** Add a title-only/body-only search choice.
  Keep the original entries unchanged and verify the same query in each mode.
- **Choice: retry policy.** Add a bounded retry for a temporary server failure
  using a controlled transport. Explain which errors qualify and stop promptly
  when the task is cancelled; do not repeatedly retry malformed data.
- **Challenge: cached reference.** Save a successful result with an explicit
  timestamp and distinguish cached data from a fresh response. Test the offline
  route and explain how stale data changes the UI contract.

## API references

- [URLSession async data request](https://developer.apple.com/documentation/foundation/urlsession/data(for:delegate:))
- [HTTP response status](https://developer.apple.com/documentation/foundation/httpurlresponse/statuscode)
- [JSONPlaceholder routes and response shape](https://jsonplaceholder.typicode.com/)
