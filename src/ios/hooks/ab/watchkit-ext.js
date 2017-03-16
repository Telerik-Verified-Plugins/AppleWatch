var path = require('path'),
    wkcommon = require('./watchkit-common'),
    debug = 'Debug',
    release = 'Release',
    watchKitExtension = 'WatchKit Extension';

function addWatchkitExtensionFrameworks(pbxProject, watchKitExtension, projectPluginDir) {
    console.log('Add WatchKit.Framework');
    var watchConnectivityFramework = pbxProject.addFramework('System/Library/Frameworks/WatchConnectivity.framework');
    var coreLocationFramework = pbxProject.addFramework('System/Library/Frameworks/CoreLocation.framework');
    var libmmwormholeLib = pbxProject.addFramework(path.join(projectPluginDir, 'libMMWormhole-watchos.a'));

    return pbxProject.addBuildPhase([watchConnectivityFramework.path, coreLocationFramework.path, libmmwormholeLib.path].filter(i => i),
        'PBXFrameworksBuildPhase', watchKitExtension + ' Frameworks');
}

function addWatchkitExtensionTarget(pbxProject, prop, bundleIdentifier) {
    console.log('Adding WatchKit Extension XCConfigurationList');
    var INHERITED = '"$(inherited)"',
        librarySearchPath = [INHERITED, '"\\"$(SRCROOT)/' + prop.projectPluginDir + '\\""'],
        watchKitExtensionConfigurations = [{
            isa: 'XCBuildConfiguration',
            buildSettings: {
                INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
                LD_RUNPATH_SEARCH_PATHS: '"$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"',
                LIBRARY_SEARCH_PATHS: librarySearchPath,
                PRODUCT_BUNDLE_IDENTIFIER: bundleIdentifier,
                PRODUCT_NAME: '"${TARGET_NAME}"',
                PROVISIONING_PROFILE: '"${PROVISION_WATCHKITEXTENSION}"',
                SDKROOT: 'watchos',
                SKIP_INSTALL: 'YES',
                TARGETED_DEVICE_FAMILY: 4,
                WATCHOS_DEPLOYMENT_TARGET: '2.0',
                CODE_SIGN_ENTITLEMENTS: '"${ENTITLEMENTS_WATCHKITEXTENSION}"',
                OTHER_LDFLAGS: ['-weak_framework', 'UIKit'],
                ENABLE_BITCODE: 'YES'
            },
            name: debug,
        }, {
            isa: 'XCBuildConfiguration',
            buildSettings: {
                INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
                LD_RUNPATH_SEARCH_PATHS: '"$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"',
                LIBRARY_SEARCH_PATHS: librarySearchPath,
                PRODUCT_BUNDLE_IDENTIFIER: bundleIdentifier,
                PRODUCT_NAME: '"${TARGET_NAME}"',
                PROVISIONING_PROFILE: '"${PROVISION_WATCHKITEXTENSION}"',
                SDKROOT: 'watchos',
                SKIP_INSTALL: 'YES',
                TARGETED_DEVICE_FAMILY: 4,
                WATCHOS_DEPLOYMENT_TARGET: '2.0',
                OTHER_LDFLAGS: ['-weak_framework', 'UIKit'],
                ENABLE_BITCODE: 'YES'
            },
            name: release,
        }];

    var watchKitExtensionXCConfigurations = pbxProject.addXCConfigurationList(watchKitExtensionConfigurations, 'Release', 'Build configuration list for PBXNativeTarget ' + prop.displayName);

    return wkcommon.addNativeTarget(pbxProject, {
        buildConfiguration: watchKitExtensionXCConfigurations,
        buildPhases:
        [{
            value: prop.sourcesBuildPhase.uuid,
            comment: watchKitExtension
        },
        {
            value: prop.buildPhase.uuid,
            comment: 'Frameworks'
        }],
        buildRules: [],
        dependencies: [],
        productName: prop.displayName,
        productReference: prop.productReference,
        productReference_comment: prop.productReference_comment,
        productType: '"com.apple.product-type.watchkit2-extension"'
    });
}

module.exports = {
    addFrameworks: addWatchkitExtensionFrameworks,
    addTarget: addWatchkitExtensionTarget
}
