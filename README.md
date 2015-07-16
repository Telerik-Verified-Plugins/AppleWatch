AppleWatch Cordova plugin
=========================

An AppleWatch plugin which requires no native code.
The Watch UI is built with plain old JavaScript!


##UI widgets
Let's start off with the fun stuff: how do we create those Watch widgets with JavaScript?


####Switch
<img src="doc/widgets/switch.png" width="266px" height="166px" alt="Switch"/>

```js
var fooSwitchOn = true;
var barSwitchOn = false;

function onFooSwitchChanged(changedTo) {
  fooSwitchOn = changedTo;
  console.log("Foo switch changed to " + changedTo);
}

'switch': {
  'title': 'Want foo?',
  'on': fooSwitchOn, // the initial state of the switch when rendering
  'color': '#CC0000', // red in this case
  'callback': 'onFooSwitchChanged' // optional, but pretty useful
},
'switch2': {
  'title': 'And bar?',
  'on': barSwitchOn,
  'color': '#02779E'
}
 ```

####Slider
<img src="doc/widgets/slider2.png" width="267px" height="113px" alt="Slider"/>

```js
var sliderValue = 50;

function onSliderChanged(val) {
  sliderValue = val;
  console.log("Slider changed to: " + val);
}

'slider': {
  'steps': 20, // of 100, so each step is 5 in this case
  'value': sliderValue, // of 100, making this essentially a percentage
  'color': '#CC0000', // the color of the dots, red in this case
  'callback': 'onSliderChanged',
  'hideValue': false // default false, shows the current value below the slider
}
 ```

####Map
<img src="doc/widgets/map.png" width="266px" height="208px" alt="Map"/>

```js
'map': {
  'center': {
    // Amersfoort, The Netherlands
    'lat': 52.1851552,
    'lng': 5.3996181
  },
  'zoom': 4.1, // 0.001 is streetlevel, 4 fits the entire Netherlands
  'annotations': [ // up to 5 annotations (custom pins), any more are ignored (play with the zoom value to make them all fit)
    {
      'pinColor': 'green', // green|red|purple
      'lat': 52.1851,
      'lng': 5.3996
    },
    {
      'pinColor': 'red',
      'lat': 51.751,
      'lng': 8.4
    },
    {
      'pinColor': 'purple',
      'lat': 50.2251,
      'lng': 4.7196
    }
  ]
}
 ```


####Button
<img src="doc/widgets/button.png" width="266px" height="250px" alt="Button"/>

All types of buttons can be styled with a bunch of properties.
Those buttons above are rendered by this code:

```js
// the red one
'userInputButton': {
  'width': 60, // default full width, see the orange buttons
  'height': 30,
  'title': {
    'value': 'Vote',
    'color': '#FFFFFF',
    'font': {
      'size': 12
    }
  },
  'backgroundColor': '#CC0000',
  'alpha': 1 // which is the default
},

// the blue one
'actionButton': {
  'title': {
    'value': 'Refresh',
    'color': 'blaaaaaaa', // because this is rubbish, we fall back to the default (black)
    'font': {
      'size': 17
    }
  },
  'color': '#FFFFFF',
  'width':80,
  'height':44
},

// the orange one
'pushNavButton': {
  'title': {
    'value': 'Push nav'
  },
  'backgroundColor': '#FFA500'
}
```

####Menu
<img src="doc/widgets/contextmenu.png" width="270px" height="324px" alt="menu"/>

This menu is triggered by a Force Touch, which is pretty neat!

The `iconNamed` property must be one of:

|`iconNamed`|image|
|-----------|-----|
|accept  |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemAccept-regular_2x.png"   width="30px" height="21px"/>|
|add     |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemAdd-regular_2x.png"      width="30px" height="21px"/>|
|block   |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemBlock-regular_2x.png"    width="30px" height="21px"/>|
|decline |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemDecline-regular_2x.png"  width="30px" height="21px"/>|
|info    |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemInfo-regular_2x.png"     width="30px" height="21px"/>|
|maybe   |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemMaybe-regular_2x.png"    width="30px" height="21px"/>|
|more    |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemMore-regular_2x.png"     width="30px" height="21px"/>|
|mute    |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemMute-regular_2x.png"     width="30px" height="21px"/>|
|pause   |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemPause-regular_2x.png"    width="30px" height="21px"/>|
|play    |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemPlay-regular_2x.png"     width="30px" height="21px"/>|
|repeat  |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemRepeat-regular_2x.png"   width="30px" height="21px"/>|
|resume  |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemResume-regular_2x.png"   width="30px" height="21px"/>|
|share   |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemShare-regular_2x.png"    width="30px" height="21px"/>|
|shuffle |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemShuffle-regular_2x.png"  width="30px" height="21px"/>|
|speaker |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemSpeaker-regular_2x.png"  width="30px" height="21px"/>|
|trash   |<img src="https://developer.apple.com/library/ios/documentation/WatchKit/Reference/WKInterfaceController_class/Art/SPMenuItemTrash-regular_2x.png"    width="30px" height="21px"/>|


```js
function onContextMenuPlay() {
  console.log("User wants to play :)");
}

'contextMenu': {
  // configure up to 4 items (any more will be ignored)
  'items': [
    {
      'title': 'Play',
      'iconNamed': 'play',
      'callback': 'onContextMenuPlay'
    },

    {
      'title': 'Resume',
      'iconNamed': 'resume',
      'callback': 'onContextMenuResume'
    }
  ]
}
```


##Installation

####Prep
Install npm 'xcode' package because our hooks need it: `npm install -g xcode`

####CLI
```
 cordova create applewatchtest
 cd applewatchtest
 cordova platform add ios
```

####XCode
File > New > Target > Apple Watch: Language ObjC, Select Glance and Notifications > Finish > Activate

####CLI
```
 cordova plugin add https://github.com/Telerik-Verified-Plugins/AppleWatch
 cordova prepare
```

####XCode
Set CFBundleVersion (Bundle Version) and CFBundleShortVersionString (Bundle versions string, short) of all targets to the same value (use XCode's search feature and change all 3 .plist values)


At this point your builds should succeed


####More XCode
App Groups: register an appgroup in your iOS member center (Identifiers > App Groups): we expect group.<packagename>, like group.io.cordova.hellocordova, then add it to your App ID.
Now generate a provisioning profile with the new App ID and add it XCode (download, then double-click the file should do it).
In XCode, go to your targets and add this app group to both the phone and watch app targets (Capabilities tab).


##Tips:
If you want a quickstart, use `demo/index.html`

The simulator doesn't support local notifications

Debugging of both the app and the extension: http://www.fiveminutewatchkit.com/blog/2015/3/13/how-to-debug-an-ios-app-while-the-associated-watchkit-app-is-running

Notifications: http://natashatherobot.com/watchkit-actionable-notifications/


##Kudos
[Lee Crossley](https://github.com/leecrossley/cordova-plugin-apple-watch) for his work on figuring out how to add and use the wormhole lib in a Cordova plugin