#!/bin/bash
set -e
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORMHOLE_FACTORY_DIR="${BASEDIR}/wormhole factory"
IPHONEOS_SDK="iphoneos"
IPHONESIMULATOR_SDK="iphonesimulator"
WATCHOS_SDK="watchos"
WATCHSIMULATOR_SDK="watchsimulator"

git submodule init && git submodule update

cp -rf "${BASEDIR}/MMWormhole/Source/" "${WORMHOLE_FACTORY_DIR}/MMWormhole/"

cd "${WORMHOLE_FACTORY_DIR}"

xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${WORMHOLE_FACTORY_DIR}/build/${IPHONEOS_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${WORMHOLE_FACTORY_DIR}/xcconfig/${IPHONEOS_SDK}.xcconfig" -sdk ${IPHONEOS_SDK} clean build
xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${WORMHOLE_FACTORY_DIR}/build/${IPHONESIMULATOR_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${WORMHOLE_FACTORY_DIR}/xcconfig/${IPHONESIMULATOR_SDK}.xcconfig" -sdk ${IPHONESIMULATOR_SDK} clean build

xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${WORMHOLE_FACTORY_DIR}/build/${WATCHOS_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${WORMHOLE_FACTORY_DIR}/xcconfig/${WATCHOS_SDK}.xcconfig" -sdk ${WATCHOS_SDK} clean build
xcodebuild -project MMWormhole.xcodeproj -scheme MMWormhole CONFIGURATION_BUILD_DIR="${WORMHOLE_FACTORY_DIR}/build/${WATCHSIMULATOR_SDK}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -configuration release -xcconfig "${WORMHOLE_FACTORY_DIR}/xcconfig/${WATCHSIMULATOR_SDK}.xcconfig" -sdk ${WATCHSIMULATOR_SDK} clean build

# Output artifacts at ${BASEDIR}/../ (src/ios/lib)
# Produce static libraries for all processor architectures for both iOS and watchOS.
lipo -c "${WORMHOLE_FACTORY_DIR}/build/${IPHONEOS_SDK}/libMMWormhole.a" "${WORMHOLE_FACTORY_DIR}/build/${IPHONESIMULATOR_SDK}/libMMWormhole.a" -o "${WORMHOLE_FACTORY_DIR}/../libMMWormhole-ios.a"
lipo -c "${WORMHOLE_FACTORY_DIR}/build/${WATCHOS_SDK}/libMMWormhole.a" "${WORMHOLE_FACTORY_DIR}/build/${WATCHSIMULATOR_SDK}/libMMWormhole.a" -o "${WORMHOLE_FACTORY_DIR}/../libMMWormhole-watchos.a"

cp -rf "${WORMHOLE_FACTORY_DIR}/build/${IPHONEOS_SDK}/Headers" "${WORMHOLE_FACTORY_DIR}/../headers"
#