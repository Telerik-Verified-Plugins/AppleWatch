#!/bin/bash
set -e
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IPHONEOS_SDK="iphoneos"
IPHONESIMULATOR_SDK="iphonesimulator"
WATCHOS_SDK="watchos"
WATCHSIMULATOR_SDK="watchsimulator"

xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${BASEDIR}/build/${IPHONEOS_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${BASEDIR}/xcconfig/${IPHONEOS_SDK}.xcconfig" -sdk ${IPHONEOS_SDK} clean build
xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${BASEDIR}/build/${IPHONESIMULATOR_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${BASEDIR}/xcconfig/${IPHONESIMULATOR_SDK}.xcconfig" -sdk ${IPHONESIMULATOR_SDK} clean build

xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${BASEDIR}/build/${WATCHOS_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${BASEDIR}/xcconfig/${WATCHOS_SDK}.xcconfig" -sdk ${WATCHOS_SDK} clean build
xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${BASEDIR}/build/${WATCHSIMULATOR_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${BASEDIR}/xcconfig/${WATCHSIMULATOR_SDK}.xcconfig" -sdk ${WATCHSIMULATOR_SDK} clean build

# Output artifacts at ${BASEDIR}/../ (src/ios/lib)
# Produce static libraries for all processor architectures for both iOS and watchOS.
lipo -c "${BASEDIR}/build/${IPHONEOS_SDK}/libMMWormhole.a" "${BASEDIR}/build/${IPHONESIMULATOR_SDK}/libMMWormhole.a" -o "${BASEDIR}/../libMMWormhole-ios.a"
lipo -c "${BASEDIR}/build/${WATCHOS_SDK}/libMMWormhole.a" "${BASEDIR}/build/${WATCHSIMULATOR_SDK}/libMMWormhole.a" -o "${BASEDIR}/../libMMWormhole-watchos.a"

cp -rf "${BASEDIR}/build/${IPHONEOS_SDK}/Headers" "${BASEDIR}/../headers"
#