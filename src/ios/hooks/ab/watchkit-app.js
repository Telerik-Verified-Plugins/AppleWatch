var path = require('path'),
    wkcommon = require('./watchkit-common'),
    debug = 'Debug',
    release = 'Release',
    watchKitApp = 'WatchKit App';

function addWatchkitAppTarget(pbxProject, prop) {
    console.log('Adding WatchKit App XCConfigurationList');
    var watchKitAppConfigurations = [{
        isa: 'XCBuildConfiguration',
        buildSettings: {
            ASSETCATALOG_COMPILER_APPICON_NAME: 'AppIcon',
            GCC_PREPROCESSOR_DEFINITIONS: [
                '"DEBUG=1"',
                '"$(inherited)"',
            ],
            IBSC_MODULE: prop.bundleDisplayName + '_WatchKit_Extension',
            INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
            IPHONEOS_DEPLOYMENT_TARGET: 8.2, //Hardcoding this - problems may arise
            PRODUCT_NAME: '"${TARGET_NAME}"',
			PROVISIONING_PROFILE: '"${PROVISION_WATCHKITAPP}"',
            SKIP_INSTALL: 'YES',
            TARGETED_DEVICE_FAMILY: 4, //Hardcoding this also
            '"TARGETED_DEVICE_FAMILY[sdk=iphonesimulator*]"': '"1,4"', // According to apple documentation 1 is for iPhone/iPad and 2 is for iPad - I'm guessing 4 is for AppleWatch
            COPY_PHASE_STRIP: 'NO',
            MTL_ENABLE_DEBUG_INFO: 'NO'
        },
        name: debug,
    }, {
            isa: 'XCBuildConfiguration',
            buildSettings: {
                ASSETCATALOG_COMPILER_APPICON_NAME: 'AppIcon',
                IBSC_MODULE: prop.bundleDisplayName + '_WatchKit_Extension',
                INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
                IPHONEOS_DEPLOYMENT_TARGET: 8.2, //Hardcoding this - problems may arise
                PRODUCT_NAME: '"${TARGET_NAME}"',
				PROVISIONING_PROFILE: '"${PROVISION_WATCHKITAPP}"',
                SKIP_INSTALL: 'YES',
                TARGETED_DEVICE_FAMILY: 4, //Hardcoding this also
                '"TARGETED_DEVICE_FAMILY[sdk=iphonesimulator*]"': '"1,4"', // According to apple documentation 1 is for iPhone/iPad and 2 is for iPad - I'm guessing 4 is for AppleWatch
                COPY_PHASE_STRIP: 'NO'
            },
            name: release,
        }];

    var watchKitAppXCConfigurations = pbxProject.addXCConfigurationList(watchKitAppConfigurations, 'Release', 'Build configuration list for PBXNativeTarget ' + prop.displayName);

    return wkcommon.addNativeTarget(pbxProject, {
        buildConfiguration: watchKitAppXCConfigurations,
        buildPhases: [{ value: prop.buildPhase.uuid, comment: watchKitApp }],
        buildRules: [],
        dependencies: [],
        productName: prop.displayName,
        productReference: prop.productReference,
        productReference_comment: prop.productReference_comment,
        productType: '"com.apple.product-type.application.watchapp"'
    });
}

module.exports = {
    addTarget: addWatchkitAppTarget
}