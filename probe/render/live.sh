#!/bin/bash
# On the live Mac: build once or again, then run a case list on every phone at once.
# usage: live.sh build | live.sh run <cases-file> [phone ...]
set -u
cd "$(dirname "$0")"
export DEVELOPER_DIR=/Applications/Xcode_27.2.app/Contents/Developer
case "$1" in
build)
  [ -d IslandRender.xcodeproj ] || xcodegen generate >/dev/null
  xcodebuild -project IslandRender.xcodeproj -scheme IslandRender -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' -derivedDataPath build build-for-testing \
    -quiet 2>&1 | grep -E "error:|warning: unre" | head -30
  xcodebuild -project IslandRender.xcodeproj -scheme IslandRenderOther -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' -derivedDataPath build build -quiet 2>&1 | grep -E "error:" | head
  while read -r phone udid; do
    xcrun simctl install "$udid" build/Build/Products/Debug-iphonesimulator/IslandRenderOther.app
    xcrun simctl install "$udid" build/Build/Products/Debug-iphonesimulator/IslandRender.app
  done < ~/live-sims.txt
  echo built ;;
run)
  cases=$(cd "$(dirname "$2")" && pwd)/$(basename "$2"); shift 2
  rm -rf ~/live-out; mkdir -p ~/live-out
  while read -r phone udid; do
    if [ $# -gt 0 ] && ! printf '%s\n' "$@" | grep -qx "$phone"; then continue; fi
    TEST_RUNNER_LIVE_CASES="$cases" TEST_RUNNER_LIVE_OUT="$HOME/live-out/$phone" \
      xcodebuild test-without-building -project IslandRender.xcodeproj -scheme IslandRender \
      -destination "id=$udid" -derivedDataPath build \
      -only-testing:IslandRenderUITests/LiveUITests/testCases > ~/live-out/$phone.log 2>&1 &
  done < ~/live-sims.txt
  wait
  for f in ~/live-out/*.log; do echo "$(basename $f .log): $(grep -c LIVE-SHOT $f) shots $(grep -E '\*\* TEST' $f | tail -1)"; done ;;
esac
