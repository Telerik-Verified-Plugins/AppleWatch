var path = require('path'),
    wkcommon = require('./watchkit-common'),
    debug = 'Debug',
    release = 'Release',
    watchKitApp = 'WatchKit App';

function addWatchkitAppTarget(pbxProject, prop, bundleIdentifier) {
    console.log('Adding WatchKit App XCConfigurationList');
    var watchKitAppConfigurations = [{
        isa: 'XCBuildConfiguration',
        buildSettings: {
            ASSETCATALOG_COMPILER_APPICON_NAME: 'AppIcon',
            IBSC_MODULE: prop.bundleDisplayName + '_WatchKit_Extension',
            INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
            PRODUCT_BUNDLE_IDENTIFIER: bundleIdentifier,
            PRODUCT_NAME: '"${TARGET_NAME}"',
            PROVISIONING_PROFILE: '"${PROVISION_WATCHKITAPP}"',
            SDKROOT: 'watchos',
            SKIP_INSTALL: 'YES',
            TARGETED_DEVICE_FAMILY: 4,
            WATCHOS_DEPLOYMENT_TARGET: '2.0',
            ENABLE_BITCODE: 'YES'
        },
        name: debug,
    }, {
        isa: 'XCBuildConfiguration',
        buildSettings: {
            ASSETCATALOG_COMPILER_APPICON_NAME: 'AppIcon',
            IBSC_MODULE: prop.bundleDisplayName + '_WatchKit_Extension',
            INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
            PRODUCT_BUNDLE_IDENTIFIER: bundleIdentifier,
            PRODUCT_NAME: '"${TARGET_NAME}"',
            PROVISIONING_PROFILE: '"${PROVISION_WATCHKITAPP}"',
            SDKROOT: 'watchos',
            SKIP_INSTALL: 'YES',
            TARGETED_DEVICE_FAMILY: 4,
            WATCHOS_DEPLOYMENT_TARGET: '2.0',
            ENABLE_BITCODE: 'YES'
        },
        name: release,
    }];

    var watchKitAppXCConfigurations = pbxProject.addXCConfigurationList(watchKitAppConfigurations, 'Release', 'Build configuration list for PBXNativeTarget ' + prop.displayName);

    return wkcommon.addNativeTarget(pbxProject, {
        buildConfiguration: watchKitAppXCConfigurations,
        buildPhases: [{
            value: prop.buildPhase.uuid,
            comment: watchKitApp
        }],
        buildRules: [],
        dependencies: [],
        productName: prop.displayName,
        productReference: prop.productReference,
        productReference_comment: prop.productReference_comment,
        productType: '"com.apple.product-type.application.watchapp2"'
    });
}

module.exports = {
    addTarget: addWatchkitAppTarget
}