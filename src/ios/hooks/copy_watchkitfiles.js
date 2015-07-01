// TODO app groups
// TODO uninstall hook.. hmm (I think no priority, because Telerik Platform will likely simply remove the entire targets)

var xcode = require('xcode'),
    pbxFile = require('xcode/lib/pbxFile'),
    path = require('path'),
    fs = require('fs');

module.exports = function (context) {

  // ----------- add files to copy here -----------
  var headerFilesToAdd = [
    "WatchKitUIHelper.h",
    "DetailInterfaceController.h",
    "GlanceController.h",
    "InterfaceController.h",
    "NotificationController.h",
    "WatchKitUIHelper.h",
    "ImageLabelRowType.h",
    "TwoColumnsRowType.h"
  ];

  var sourceFilesToAdd = [
    "WatchKitUIHelper.m",
    "DetailInterfaceController.m",
    "GlanceController.m",
    "InterfaceController.m",
    "NotificationController.m",
    "WatchKitUIHelper.m",
    "ImageLabelRowType.m",
    "TwoColumnsRowType.m"
  ];

  var storyboardToAdd = "Interface.storyboard";
  // ----------- end files ------------------------

  var projectRoot = context.opts.projectRoot;

  function pbxGroupChild(file) {
    var obj = Object.create(null);
    obj.value = file.fileRef;
    obj.comment = file.basename;
    return obj;
  }

  printLogo();

  function addHeaderFile(filename, opt, myProj, watchKitExtensionPbxGroup) {
    return addFile(filename, opt, myProj, watchKitExtensionPbxGroup);
  }

  function addSourceFile(filename, opt, myProj, watchKitExtensionPbxGroup) {
    var file = addFile(filename, opt, myProj, watchKitExtensionPbxGroup);

    if (!file) return false;

    file.target = opt ? opt.target : undefined;
    file.uuid = myProj.generateUuid();

    myProj.addToPbxBuildFileSection(file);
    myProj.addToPbxSourcesBuildPhase(file);

    return file;
  }

  function addFrameworkReferenceToTarget(filename, opt, appName) {
    var groups = myProj.hash.project.objects['PBXFrameworksBuildPhase'], key, fKey;

    var pluginLib;

    for (key in groups) {
      var frameworks = groups[key];
      for (fKey in frameworks.files) {
        var fwkFile = frameworks.files[fKey];
        if (fwkFile.comment.indexOf(filename) > -1) {
          pluginLib = fwkFile;
          break;
        }
      }
      // we only care about the first group
      break;
    }


    var libFileRef;
    var pbxBuildFiles = myProj.pbxBuildFileSection();
    for (var buildFileKey in pbxBuildFiles) {
      if (buildFileKey == pluginLib.value) {
        libFileRef = pbxBuildFiles[buildFileKey].fileRef;
      }
    }

    var file = new pbxFile(filename, opt);
    if (myProj.hasFile(file.path)) return null;
    file.fileRef = libFileRef;
    file.target = opt ? opt.target : undefined;
    file.uuid = myProj.generateUuid();
    myProj.addToPbxBuildFileSection(file);


    myProj.addToPbxFrameworksBuildPhase(file);    // PBXFrameworksBuildPhase


    // addToLibrarySearchPaths
    var configurations = myProj.pbxXCBuildConfigurationSection(),
        INHERITED = '"$(inherited)"',
        config, buildSettings, searchPaths;

    for (config in configurations) {
      if (config === undefined) {
        continue;
      }
      buildSettings = configurations[config].buildSettings;

      if (buildSettings === undefined ||
          buildSettings['INFOPLIST_FILE'] === undefined ||
          buildSettings['INFOPLIST_FILE'].indexOf("WatchKit Extension") == -1) {
        continue;
      }

      if (!buildSettings['LIBRARY_SEARCH_PATHS']
          || buildSettings['LIBRARY_SEARCH_PATHS'] === INHERITED) {
        buildSettings['LIBRARY_SEARCH_PATHS'] = [INHERITED];
      }

      var addThis = "\"$(PROJECT_DIR)/" + appName + "/Plugins/cordova-plugin-applewatch\"";

      // prevent duplicates
      for (k in buildSettings['LIBRARY_SEARCH_PATHS']) {
        if (addThis == buildSettings['LIBRARY_SEARCH_PATHS'][k]) {
          return;
        }
      }
      buildSettings['LIBRARY_SEARCH_PATHS'].push(addThis);
      console.log("Added framework reference for " + filename + " to target " + appName);
    }
  }

  function addFile(filename, opt, myProj, watchKitExtensionPbxGroup) {
    var file = new pbxFile(filename, opt);

    if (myProj.hasFile(file.path)) return null;

    file.fileRef = myProj.generateUuid();

    myProj.addToPbxFileReferenceSection(file);
    watchKitExtensionPbxGroup.children.push(pbxGroupChild(file));

    return file;
  }

  var project = projectRoot + "/platforms/ios";
  var xcodeproj_dir = fs.readdirSync(project).filter(function (e) {
    return e.match(/\.xcodeproj$/i);
  })[0];
  var xcodeproj = path.join(project, xcodeproj_dir);
  var pbxproj = path.join(xcodeproj, 'project.pbxproj');
  var myProj = xcode.project(pbxproj);

  var prefix = 'plugins/cordova-plugin-applewatch/src/ios/';
  var sourceHeadPrefix = prefix + 'watchkitextension/controllers/';
  var storyboardPrefix = prefix + 'watchkitapp/storyboards/';

  myProj.parseSync();

  var groups = myProj.hash.project.objects['PBXNativeTarget'], key, groupKey;

  var watchKitExtensionTargetID;
  var watchKitExtensionTargetName;
  var watchKitAppTargetName;
  var appName;

  for (key in groups) {
    // only look for comments
    if (!/_comment$/.test(key)) continue;
    groupKey = key.split(/_comment$/)[0];
    var theval = groups[groupKey];
    if (theval.productType == "\"com.apple.product-type.application\"") {
      appName = theval.name;
    } else if (theval.productType == "\"com.apple.product-type.watchkit-extension\"") {
      watchKitExtensionTargetID = groupKey;
      watchKitExtensionTargetName = theval.name;
      // the name is encapsulated in double quotes, so strip those
      watchKitExtensionTargetName = watchKitExtensionTargetName.substr(1, watchKitExtensionTargetName.length - 2);
    } else if (theval.productType == "\"com.apple.product-type.application.watchapp\"") {
      watchKitAppTargetName = theval.name;
      watchKitAppTargetName = watchKitAppTargetName.substr(1, watchKitAppTargetName.length - 2);
    }
  }

  if (watchKitExtensionTargetName === undefined) {
    console.log("No WatchKit Extension found, please open your project in XCode, then do: File > New > Target > Apple Watch > WatchKit App");
    return;
  }

  var watchKitExtensionPbxGroup = myProj.pbxGroupByName(watchKitExtensionTargetName);

  sourceFilesToAdd.forEach(function (val) {
    var fullfilename = path.join(sourceHeadPrefix, val);
    if (fs.existsSync(fullfilename)) {
      if (addSourceFile(val, {'target': watchKitExtensionTargetID}, myProj, watchKitExtensionPbxGroup)) {
        console.log("Added source file " + val + " to " + watchKitExtensionTargetName);
      //} else {
      //  console.log("Didn't add source file " + val + " to " + watchKitExtensionTargetName + " (already there?)");
      }
      // write the file - in the best plugin tradion, we will boldly overwrite any existing files
      fs.createReadStream(fullfilename).pipe(fs.createWriteStream('platforms/ios/' + watchKitExtensionTargetName + '/' + val));
    } else {
      console.log("missing source file: " + fullfilename);
    }
  });

  headerFilesToAdd.forEach(function (val) {
    var fullfilename = path.join(sourceHeadPrefix, val);
    if (fs.existsSync(fullfilename)) {
      if (addHeaderFile(val, {'target': watchKitExtensionTargetID}, myProj, watchKitExtensionPbxGroup)) {
        console.log("Added header file " + val + " to " + watchKitExtensionTargetName);
      //} else {
      //  console.log("Didn't add header file " + val + " to " + watchKitExtensionTargetName + " (already there?)");
      }
      // write the file - in the best plugin tradion, we will boldly overwrite any existing files
      fs.createReadStream(fullfilename).pipe(fs.createWriteStream('platforms/ios/' + watchKitExtensionTargetName + '/' + val));
    } else {
      console.log("missing header file: " + fullfilename);
    }
  });

  addFrameworkReferenceToTarget("libmmwormhole.a", {'target': watchKitExtensionTargetID}, appName);

  // the storyboard only needs to be copied because we only have one (the default) at the moment
  var fullfilename = path.join(storyboardPrefix, storyboardToAdd);
  fs.createReadStream(fullfilename).pipe(fs.createWriteStream('platforms/ios/' + watchKitAppTargetName + '/' + storyboardToAdd));
  console.log("Copied " + storyboardToAdd + " to " + watchKitAppTargetName);

// write the updated project file
  fs.writeFileSync(pbxproj, myProj.writeSync());


  function printLogo() {
    console.log("");
    console.log("");
    console.log("");
    console.log("                                 Configuring the                                      ");
    console.log("                             Cordova AppleWatch Plugin                                ");
    console.log("                                                                                      ");
    console.log("                          `@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:                             ");
    console.log("                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`                           ");
    console.log("                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:                          ");
    console.log("                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                          ");
    console.log("                      ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@#  @@@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@                 ");
    console.log("                      @@@@@@@@@@@@@@@`   ,`    @@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@@`          ,@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@@          `@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@'          @@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@,          @@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@;          @@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@@           @@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@            @@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@            @@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@          +@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@:         @@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@.  +#   @@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@                   ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;                        ");
    console.log("                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         ");
    console.log("                      ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         ");
    console.log("                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                          ");
    console.log("                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:                          ");
    console.log("                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`                           ");
    console.log("                          `@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:                             ");
    console.log("");
  }
};