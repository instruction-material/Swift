#!/usr/bin/env bash
set -euo pipefail

# Run on the hosted macOS runner with a disposable simulator and build folder.
project=$(mktemp -d "${RUNNER_TEMP:?}/gallery-card.XXXXXX")
cp -R SW14-Accessible-Tasks/solution/TaskReview.xcodeproj "$project/"
mkdir "$project/Tests"
cp SAD2-Media-Gallery-App/starter/ContentView.swift "$project/"
cp SAD2-Media-Gallery-App/starter/MediaGalleryApp.swift "$project/TaskReviewApp.swift"
cp tests/GalleryCardUITests.swift "$project/Tests/TaskReviewUITests.swift"
device=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
print(next(d["udid"] for runtime, devices in json.load(sys.stdin)["devices"].items()
           if ".iOS-" in runtime for d in devices if d["name"].startswith("iPhone") and d["isAvailable"]))')
xcodebuild test -project "$project/TaskReview.xcodeproj" -scheme TaskReview \
  -destination "id=$device" -parallel-testing-enabled NO \
  -derivedDataPath "$project/build" -resultBundlePath "$project/card.xcresult" \
  -only-testing:TaskReviewUITests/GalleryCardUITests/testStarterCardExposesItsTitleAndDescriptionOnce
mkdir -p output
xcrun xcresulttool get test-results tests --path "$project/card.xcresult" > output/gallery-card-tests.json
python3 - <<'PY'
import json
from pathlib import Path

def cases(nodes):
    for node in nodes:
        if node["nodeType"] == "Test Case":
            yield node
        yield from cases(node.get("children", []))

result, = cases(json.loads(Path("output/gallery-card-tests.json").read_text())["testNodes"])
assert "testStarterCardExposesItsTitleAndDescriptionOnce" in result["name"], result
assert result["result"] == "Passed", result
PY
