var xcode = require('xcode'),
    path = require('path'),
    fs = require('fs');

module.exports = function (context) {

  var projectRoot = context.opts.projectRoot;
  var iosPlatformFolder = "/platforms/ios";
  var project = projectRoot + iosPlatformFolder;
  var customStoryboardProjectFolder = "/www/custom-watchkit-storyboards";
  var customStoryboardFolder = project + customStoryboardProjectFolder;
  var customStoryboardName = "Interface.storyboard";

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
    }
  }

  if (watchKitAppTargetName === undefined) {
    console.log("No WatchKit App found, please open your project in XCode, then do: File > New > Target > Apple Watch > WatchKit App");
    return;
  }

  // the storyboard only needs to be copied because we only have one (the default) at the moment
  var fullfilename = path.join(customStoryboardFolder, customStoryboardName);
  if (fs.existsSync(fullfilename)) {
    fs.createReadStream(fullfilename).pipe(fs.createWriteStream('platforms/ios/' + watchKitAppTargetName + '/Base.lproj/' + customStoryboardName));
    console.log("Copied your custom " + customStoryboardName + " to " + watchKitAppTargetName);
  } else {
    console.log("No custom WatchKit storyboard found. If you want one, provide it here: " + iosPlatformFolder + customStoryboardProjectFolder + customStoryboardName);
  }
};