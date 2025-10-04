#!/bin/zsh

cd "$(dirname "$0")"

while [[ ! -d .git ]] && [[ "$(pwd)" != "/" ]]; do
    cd ..
done

if [[ -d .git ]] && [[ -d BreakGlass.xcodeproj ]]; then
    echo "[*] found project root: $(pwd)"
else
    echo "[!] could not find project root"
    exit 1
fi

PROJECT_ROOT=$(pwd)

xcodebuild -project BreakGlass.xcodeproj \
    -scheme BreakGlass \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$PROJECT_ROOT/.build/BreakGlass.xcarchive" \
    archive | xcbeautify -q

echo "[*] done"
