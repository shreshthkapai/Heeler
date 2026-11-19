#!/bin/bash
# One UI test method on the booted Simulator; its screenshots land in $OUT/<method>.
set -u
name=$1
for attempt in 1 2; do
xcodebuild test-without-building -project IslandRender.xcodeproj -scheme IslandRender \
  -destination "id=$UDID" -derivedDataPath build -resultBundlePath "$OUT/$name.xcresult" \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 1500 \
  -maximum-test-execution-time-allowance 1500 \
  -only-testing:"IslandRenderUITests/RenderUITests/$name" > "$OUT/$name.log" 2>&1
status=$?
grep -E "Test Case|error|passed|failed" "$OUT/$name.log" | tail -10
xcrun xcresulttool export attachments --path "$OUT/$name.xcresult" --output-path "$OUT/$name"
rm -rf "$OUT/$name.xcresult"
shots=$(ls "$OUT/$name" 2>/dev/null | grep -c png)
echo "attempt $attempt: $shots screenshots"
[ "$shots" -gt 0 ] && break
rm -rf "$OUT/$name"
done
exit 0
