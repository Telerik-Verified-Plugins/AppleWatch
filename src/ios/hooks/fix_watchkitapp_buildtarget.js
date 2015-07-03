var xcode = require('xcode'),
    path = require('path'),
    fs = require('fs');

module.exports = function (context) {
  var projectRoot = context.opts.projectRoot;
  var setDeploymentTargetTo = 8.2;

  function changeBuildTarget(newDeploymentTarget, appName) {
    var configurations = myProj.pbxXCBuildConfigurationSection(), config, buildSettings;

    var i=0;
    for (config in configurations) {
      if (config === undefined || config.indexOf("_comment") > -1) {
        continue;
      }

      buildSettings = configurations[config].buildSettings;
      if (buildSettings['INFOPLIST_FILE'] !== undefined && buildSettings['INFOPLIST_FILE'].indexOf(appName) > -1) {
        buildSettings['IPHONEOS_DEPLOYMENT_TARGET'] = newDeploymentTarget;
        // we need to change two targets
        if (++i == 2) {
          console.log("Changed debug and release deployment targets of " + appName + " to " + newDeploymentTarget);
          break;
        }
      }
    }
  }

  var project = projectRoot + "/platforms/ios";
  var xcodeproj_dir = fs.readdirSync(project).filter(function (e) {
    return e.match(/\.xcodeproj$/i);
  })[0];
  var xcodeproj = path.join(project, xcodeproj_dir);
  var pbxproj = path.join(xcodeproj, 'project.pbxproj');
  var myProj = xcode.project(pbxproj);

  myProj.parseSync();

  var groups = myProj.hash.project.objects['PBXNativeTarget'], key, groupKey;
  var watchKitAppTargetName;
  for (key in groups) {
    // only look for comments
    if (!/_comment$/.test(key)) continue;
    groupKey = key.split(/_comment$/)[0];
    var theval = groups[groupKey];
    if (theval.productType == "\"com.apple.product-type.application.watchapp\"") {
      watchKitAppTargetName = theval.name;
      watchKitAppTargetName = watchKitAppTargetName.substr(1, watchKitAppTargetName.length - 2);
      break;
    }
  }

  // the other script will complain if no target can be found
  if (watchKitAppTargetName !== undefined) {
    changeBuildTarget(setDeploymentTargetTo, watchKitAppTargetName);

    // write the updated project file
    fs.writeFileSync(pbxproj, myProj.writeSync());
  }
};