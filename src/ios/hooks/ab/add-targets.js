var fs = require('fs'),
    path = require('path'),
    wrench = require('wrench'),
    plist = require('plist'),
    util = require('util'),
    wkapp = require('./watchkit-app'),
    wkext = require('./watchkit-ext'),
    wkcommon = require('./watchkit-common'),
    watchKitApp = 'watchkitapp',
    watchKitExtension = 'watchkitextension',
    embedAppExtensions = 'Embed App Extensions',
    interfaceStoryBoard = 'Interface.storyboard',
    base = 'Base',
    baseLproj = 'Base.lproj',
    commentKeyRegex = /_comment$/;

module.exports = function (context) {
    var projectRoot = context.opts.projectRoot,
        xcodeProjectPath = fs.readdirSync(projectRoot).filter(function (file) { return ~file.indexOf('.xcodeproj') && fs.statSync(path.join(projectRoot, file)).isDirectory(); })[0],
        cordovaProjectName = xcodeProjectPath.slice(0, -'.xcodeproj'.length),
        projectPlistPath = path.join(projectRoot, cordovaProjectName, util.format('%s-Info.plist', cordovaProjectName)),
        projectPlistJson = plist.parse(fs.readFileSync(projectPlistPath, 'utf8')),
        displayName = projectPlistJson['CFBundleDisplayName'],
        projectFile = context.opts.cordova.project.parseProjectFile(projectRoot),
        pbxProject = projectFile.xcode,
        projectRelativePluginDirPath = path.join(cordovaProjectName, 'Plugins', context.opts.plugin.id),
        resourcesPath = path.join(context.opts.plugin.dir, 'src/ios/resources'),
        watchKitAppPath = path.join(resourcesPath, watchKitApp),
        watchKitExtensionPath = path.join(resourcesPath, watchKitExtension),
        projectWatchKitAppPath = path.join(projectRoot, util.format("%s %s", displayName, watchKitApp)),
        projectWatchKitExtensionPath = path.join(projectRoot, util.format("%s %s", displayName, watchKitExtension)),
        watchKitAppPlistFilePath = path.join(projectWatchKitAppPath, "Info.plist"),
        watchKitExtensionPlistFilePath = path.join(projectWatchKitExtensionPath, "Info.plist"),
        pbxProjectSection = pbxProject.pbxProjectSection(),
        watchKitAppDisplayName = '"' + displayName + ' WatchKit App"',
        watchKitExtensionDisplayName = '"' + displayName + ' WatchKit Extension"',
        watchKitAppFilename = displayName + ' WatchKit App.app',
        watchKitExtensionAppexFileName = displayName + ' WatchKit Extension.appex',
		extEntitlementsFileName = "watchkitextension.entitlements",
		extEntitlementsSourceFile = path.join(resourcesPath, extEntitlementsFileName),
		extEntitlementsTargetFile = path.join(projectRoot, cordovaProjectName, extEntitlementsFileName),
        placeHolderValues = [
            {
                placeHolder: '__DISPLAY_NAME__',
                value: displayName
            },
            {
                placeHolder: '__APP_IDENTIFIER__',
                value: projectPlistJson['CFBundleIdentifier']
            },
            {
                placeHolder: '__BUNDLE_SHORT_VERSION_STRING__',
                value: projectPlistJson['CFBundleShortVersionString']
            },
            {
                placeHolder: '__BUNDLE_VERSION__',
                value: projectPlistJson['CFBundleVersion']
            }
        ],
        i = 0;

    console.log('Copying contents of WatchKit App');
    wrench.copyDirSyncRecursive(watchKitAppPath, projectWatchKitAppPath);
    console.log('Copying contents of WatchKit Extensions');
    wrench.copyDirSyncRecursive(watchKitExtensionPath, projectWatchKitExtensionPath);
    console.log('Copying entitlements file for WatchKit Extensions');
	fs.writeFileSync(extEntitlementsTargetFile, fs.readFileSync(extEntitlementsSourceFile));

    console.log('Modifying Plist files');
    wkcommon.replacePlaceholdersInPlist(watchKitAppPlistFilePath, placeHolderValues);
    wkcommon.replacePlaceholdersInPlist(watchKitExtensionPlistFilePath, placeHolderValues);

    var projectWatchKitAppPathContents = fs.readdirSync(projectWatchKitAppPath);
    console.log('Adding WatchKit App files to pbxproject');
    var watchAppArray = [];
    for (i = 0; i < projectWatchKitAppPathContents.length; i++) {
        var file = projectWatchKitAppPathContents[i];
        if (file === baseLproj) {
            continue;
        }

        watchAppArray.push(path.join(projectWatchKitAppPath, file));
    }

    var projectWatchKitExtensionPathContents = fs.readdirSync(projectWatchKitExtensionPath);
    console.log('Adding WatchKit Extension files to pbxproject');
    var watchExtArray = [];
    for (i = 0; i < projectWatchKitExtensionPathContents.length; i++) {
        watchExtArray.push(path.join(projectWatchKitExtensionPath, projectWatchKitExtensionPathContents[i]));
    }
    
    // Special case Interface.storyboard
    // Interface.storyboard is the only file so far 
    // which is inconsistent between the PBXBuildFile and PBXFileReference sections 
    var storyBoardPath = path.join(projectWatchKitAppPath, baseLproj, interfaceStoryBoard),
        storyBoardBuildFile = {
            uuid: pbxProject.generateUuid(),
            fileRef: pbxProject.generateUuid(),
            basename: interfaceStoryBoard,
        },
        storyBoardReferenceFile = {
            fileRef: pbxProject.generateUuid(),
            lastType: 'file.storyboard',
            name: base,
            path: storyBoardPath,
            sourceTree: '"<group>"',
            basename: base, //this is actually a comment          
        }

    pbxProject.addToPbxBuildFileSection(storyBoardBuildFile);
    pbxProject.addToPbxFileReferenceSection(storyBoardReferenceFile);
    // ---------------------------------------
    
    console.log('App Phase GUID');
    var watchKitAppBuildPhase = pbxProject.addBuildPhase(watchAppArray, 'PBXResourcesBuildPhase', watchKitApp);
    // Add the storyboard
    watchKitAppBuildPhase.buildPhase.files.push({ value: storyBoardBuildFile.uuid, comment: interfaceStoryBoard });

    console.log('Extension Phase GUID');
    var watchKitExtensionSourcesBuildPhase = pbxProject.addBuildPhase(watchExtArray, 'PBXSourcesBuildPhase', watchKitExtension);

    var watchKitAppPbxGroup = pbxProject.addPbxGroup(watchAppArray, watchKitAppDisplayName, watchKitAppDisplayName);
    // Add the storyboard
    watchKitAppPbxGroup.pbxGroup.children.push({ value: storyBoardBuildFile.fileRef, comment: interfaceStoryBoard });

    var watchKitExtensionPbxGroup = pbxProject.addPbxGroup(watchExtArray, watchKitExtensionDisplayName, watchKitExtensionDisplayName);

    console.log('Creating PBXVariantGroup');
    // This is storyboard-related
    pbxProject.hash.project.objects['PBXVariantGroup'] = pbxProject.hash.project.objects['PBXVariantGroup'] || {};
    pbxProject.hash.project.objects['PBXVariantGroup'][storyBoardBuildFile.fileRef] = {
        isa: 'PBXVariantGroup',
        children: [{ value: storyBoardReferenceFile.fileRef, comment: storyBoardReferenceFile.name }],
        name: interfaceStoryBoard,
        sourceTree: '"<group>"'
    };
    pbxProject.hash.project.objects['PBXVariantGroup'][storyBoardBuildFile.fileRef + '_comment'] = interfaceStoryBoard;

    console.log('Writing to PBXProject');
    var watchKitExtensionAppexFile = {
        uuid: pbxProject.generateUuid(),
        fileRef: pbxProject.generateUuid(),
        explicitFileType: '"wrapper.app-extension"',
        includeInIndex: 0,
        basename: watchKitExtensionAppexFileName,
        path: watchKitExtensionAppexFileName,
        sourceTree: 'BUILT_PRODUCTS_DIR',
        settings: { ATTRIBUTES: ['RemoveHeadersOnCopy'] }
    };

    pbxProject.addToPbxFileReferenceSection(watchKitExtensionAppexFile);
    pbxProject.addToPbxBuildFileSection(watchKitExtensionAppexFile);

    var watchKitAppFile = {
        uuid: pbxProject.generateUuid(),
        fileRef: pbxProject.generateUuid(),
        explicitFileType: 'wrapper.application',
        includeInIndex: 0,
        basename: watchKitAppFilename,
        path: watchKitAppFilename,
        sourceTree: 'BUILT_PRODUCTS_DIR'
    };

    pbxProject.addToPbxFileReferenceSection(watchKitAppFile);
    pbxProject.addToPbxBuildFileSection(watchKitAppFile);

    var watchKitExtensionResourcesBuildPhase = pbxProject.addBuildPhase([watchKitAppFile.path], 'PBXResourcesBuildPhase', watchKitExtension + ' Resources');

    pbxProject.pbxGroupByName('CustomTemplate').children.push({ value: watchKitAppPbxGroup.uuid, comment: watchKitAppDisplayName }, { value: watchKitExtensionPbxGroup.uuid, comment: watchKitExtensionDisplayName });
    pbxProject.pbxGroupByName('Products').children.push({ value: watchKitAppFile.fileRef, comment: watchKitAppFilename }, { value: watchKitExtensionAppexFile.fileRef, comment: watchKitExtensionAppexFileName });

    var watchKitFrameworkBuildPhase = wkext.addFrameworks(pbxProject, watchKitExtension, projectRelativePluginDirPath);
    var watchKitExtensionNativeTargetGuid = wkext.addTarget(pbxProject,
        {
            plistFilePath: watchKitExtensionPlistFilePath,
            displayName: watchKitExtensionDisplayName,
            projectPluginDir: projectRelativePluginDirPath,
            buildPhase: watchKitFrameworkBuildPhase,
            sourcesBuildPhase: watchKitExtensionSourcesBuildPhase,
            resourcesBuildPhase: watchKitExtensionResourcesBuildPhase,
            productReference: watchKitExtensionAppexFile.fileRef,
            productReference_comment: watchKitExtensionAppexFileName,
        });

    var watchKitAppNativeTargetGuid = wkapp.addTarget(pbxProject,
        {
            plistFilePath: watchKitAppPlistFilePath,
            displayName: watchKitAppDisplayName,
            bundleDisplayName: displayName,
            buildPhase: watchKitAppBuildPhase,
            productReference: watchKitAppFile.fileRef,
            productReference_comment: watchKitAppFilename
        });

    var pbxNativeTargetSection = pbxProject.pbxNativeTarget();

    console.log('Adding both targets to the main project');
    var pbxProjectKey = pbxProject.hash.project.rootObject;
    pbxProjectSection[pbxProjectKey].targets.push({ value: watchKitAppNativeTargetGuid, comment: watchKitAppDisplayName }, { value: watchKitExtensionNativeTargetGuid, comment: watchKitExtensionDisplayName });

    var mainAppTarget = pbxProject.pbxTargetByName(cordovaProjectName);
    var mainAppTargetGuid = getUuidByComment(cordovaProjectName, pbxNativeTargetSection);
    console.log('Add Embed App Extensions Build Phase');
    pbxProject.hash.project.objects['PBXCopyFilesBuildPhase'] = pbxProject.hash.project.objects['PBXCopyFilesBuildPhase'] || {};
    var embedAppExtensionsBuildPhase = pbxProject.addBuildPhase([watchKitExtensionAppexFileName], 'PBXCopyFilesBuildPhase', embedAppExtensions);
    embedAppExtensionsBuildPhase.buildPhase['dstPath'] = '""';
    embedAppExtensionsBuildPhase.buildPhase['dstSubfolderSpec'] = 13;
    mainAppTarget.buildPhases.push({ value: embedAppExtensionsBuildPhase.uuid, comment: embedAppExtensions });

    console.log('Adding dependencies');
    console.log('WatchKit Extension depends on WatchKit App');
    pbxProject.addTargetDependency(watchKitExtensionNativeTargetGuid, [watchKitAppNativeTargetGuid]);

    console.log('Original App depends on WatchKit Extension');
    pbxProject.addTargetDependency(mainAppTargetGuid, [watchKitExtensionNativeTargetGuid]);

    var buffer = pbxProject.writeSync();
    projectFile.write();
    console.log('pbxProject was modified successfully');
}

function getUuidByComment(comment, section) {
    for (var key in section) {
        if (!commentKeyRegex.test(key)) continue;

        if (section[key] == comment) {
            return key.split(commentKeyRegex)[0];
        }
    }

    return null;
}