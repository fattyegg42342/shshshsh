#!/bin/bash
set -e
cd "$(dirname "$0")/.."
xcodegen generate
rm -rf build Payload LegacyiOS-unsigned.ipa
xcodebuild -project LegacyiOS.xcodeproj -scheme LegacyiOS -configuration Release -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
mkdir Payload
cp -R build/Build/Products/Release-iphoneos/LegacyiOS.app Payload/
zip -qry LegacyiOS-unsigned.ipa Payload
