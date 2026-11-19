#!/bin/bash
# One UI test method on the booted Simulator; its screenshots land in $OUT/<method>.
set -u
name=$1
xcodebuild test-without-building -project IslandRender.xcodeproj -scheme IslandRender \
  -destination "id=$UDID" -derivedDataPath build -resultBundlePath "$OUT/$name.xcresult" \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 600 \
  -maximum-test-execution-time-allowance 720 \
  -only-testing:"IslandRenderUITests/RenderUITests/$name" > "$OUT/$name.log" 2>&1
status=$?
grep -E "Test Case|error|passed|failed" "$OUT/$name.log" | tail -10
xcrun xcresulttool export attachments --path "$OUT/$name.xcresult" --output-path "$OUT/$name"
rm -rf "$OUT/$name.xcresult"
ls "$OUT/$name" | wc -l
exit 0
