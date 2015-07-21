var path = require('path'),
    wkcommon = require('./watchkit-common'),
    debug = 'Debug',
    release = 'Release',
    watchKitExtension = 'WatchKit Extension';

function addWatchkitExtensionFrameworks(pbxProject, watchKitExtension, projectPluginDir) {
    console.log('Add WatchKit.Framework');
    var watchKitFramework = pbxProject.addFramework('System/Library/Frameworks/WatchKit.framework');
    var coreLocationFramework = pbxProject.addFramework('System/Library/Frameworks/CoreLocation.framework');
    var libmmwormholeLib = pbxProject.addFramework(path.join(projectPluginDir, 'libmmwormhole.a'));
    return pbxProject.addBuildPhase(
        [watchKitFramework.path, coreLocationFramework.path, libmmwormholeLib.path],
        'PBXFrameworksBuildPhase',
        watchKitExtension + ' Frameworks');
}

function addWatchkitExtensionTarget(pbxProject, prop) {
    console.log('Adding WatchKit Extension XCConfigurationList');
    var INHERITED = '"$(inherited)"',
        librarySearchPath = [INHERITED, '"\\"$(SRCROOT)/' + prop.projectPluginDir + '\\""'],
        watchKitExtensionConfigurations = [{
            isa: 'XCBuildConfiguration',
            buildSettings: {
                GCC_PREPROCESSOR_DEFINITIONS: [
                    '"DEBUG=1"',
                    INHERITED,
                ],
                INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
                LD_RUNPATH_SEARCH_PATHS: '"$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"',
                PRODUCT_NAME: '"${TARGET_NAME}"',
				CODE_SIGN_ENTITLEMENTS: '"${ENTITLEMENTS_WATCHKITEXTENSION}"',
				PROVISIONING_PROFILE: '"${PROVISION_WATCHKITEXTENSION}"',
                IPHONEOS_DEPLOYMENT_TARGET: 8.2, //Hardcoding this - problems may arise
                SKIP_INSTALL: 'YES',
                COPY_PHASE_STRIP: 'NO',
                GCC_OPTIMIZATION_LEVEL: 0,
                LIBRARY_SEARCH_PATHS: librarySearchPath
            },
            name: debug,
        }, {
                isa: 'XCBuildConfiguration',
                buildSettings: {
                    INFOPLIST_FILE: wkcommon.quoteString(prop.plistFilePath),
                    LD_RUNPATH_SEARCH_PATHS: '"$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"',
                    PRODUCT_NAME: '"${TARGET_NAME}"',
					CODE_SIGN_ENTITLEMENTS: '"${ENTITLEMENTS_WATCHKITEXTENSION}"',
					PROVISIONING_PROFILE: '"${PROVISION_WATCHKITEXTENSION}"',
                    IPHONEOS_DEPLOYMENT_TARGET: 8.2, //Hardcoding this - problems may arise
                    SKIP_INSTALL: 'YES',
                    COPY_PHASE_STRIP: 'NO',
                    VALIDATE_PRODUCT: 'YES',
                    LIBRARY_SEARCH_PATHS: librarySearchPath
                },
                name: release,
            }
        ];

    var watchKitExtensionXCConfigurations = pbxProject.addXCConfigurationList(watchKitExtensionConfigurations, 'Release', 'Build configuration list for PBXNativeTarget ' + prop.displayName);

    return wkcommon.addNativeTarget(pbxProject, {
        buildConfiguration: watchKitExtensionXCConfigurations,
        buildPhases: [{ value: prop.sourcesBuildPhase.uuid, comment: watchKitExtension },
            { value: prop.resourcesBuildPhase.uuid, comment: 'Resources' },
            { value: prop.buildPhase.uuid, comment: 'Frameworks' }],
        buildRules: [],
        dependencies: [],
        productName: prop.displayName,
        productReference: prop.productReference,
        productReference_comment: prop.productReference_comment,
        productType: '"com.apple.product-type.watchkit-extension"'
    });
}

module.exports = {
    addFrameworks: addWatchkitExtensionFrameworks,
    addTarget: addWatchkitExtensionTarget
}