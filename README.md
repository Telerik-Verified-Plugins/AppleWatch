AppleWatch Config steps (for Cordova CLI users):
================================================

DO NOT USE YET AS EVERYTHING IS IN ALPHA STATE AND WILL CHANGE!


####Prep:
  Install npm 'xcode' package because our hooks need it: `npm install -g xcode`

####CLI:
```
 cordova create applewatchtest
 cd applewatchtest
 cordova platform add ios
```

####XCode:
 File > New > Target > Apple Watch: Language ObjC, Select Glance and Notifications > Finish > Activate

####CLI:
```
 cordova plugin add https://github.com/Telerik-Verified-Plugins/AppleWatch
 cordova prepare
```

####XCode:
 Set CFBundleVersion (Bundle Version) and CFBundleShortVersionString (Bundle versions string, short) of all targets to the same value (use XCode's search feature and change all 3 .plist values


At this point your builds should succeed



####XCode:
 App Groups: register an appgroup in your iOS member center (Identifiers > App Groups): group.<packagename> will do, like group.io.cordova.hellocordova, then add it to your App ID. Now generate a provisioning profile with the new App ID and add it XCode (download, then double-click the file should do it). In XCode, go to your targets and add this app group to both the phone and watch app targets (Capabilities tab).

 Also, in `InterfaceController.m` and `demo/index.html` there's a reference to the appgroup, correct this ID. We will remove this manual step asap!

  --> TODO figure out adding app group capability for Cordova app via plugin.xml? See old version of healthkit plugin.xml



####Tips:
 If you want a quickstart, use `demo/index.html`

 The simulator doesn't support local notifications

 Debugging of both the app and the extension: http://www.fiveminutewatchkit.com/blog/2015/3/13/how-to-debug-an-ios-app-while-the-associated-watchkit-app-is-running

 Notifications: http://natashatherobot.com/watchkit-actionable-notifications/