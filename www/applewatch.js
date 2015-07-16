var exec = require("cordova/exec");

var AppleWatch = function () {
};

AppleWatch.prototype.init = function (onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "init", []);
};

AppleWatch.prototype.registerNotifications = function (onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "registerNotifications", []);
};

AppleWatch.prototype.loadGlance = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "loadGlance", [{
    "payload": payload
  }]);
};

AppleWatch.prototype.loadAppMain = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "loadAppMain", [{
    "payload": payload
  }]);
};

AppleWatch.prototype.loadAppDetail = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "loadAppDetail", [{
    "payload": payload
  }]);
};

AppleWatch.prototype.navigateToAppDetail = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "navigateToAppDetail", [{
    "payload": payload
  }]);
};

AppleWatch.prototype.navigateToAppMain = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "navigateToAppMain", [{
    "payload": payload
  }]);
};

AppleWatch.prototype.sendNotification = function (onSuccess, onError, payload) {
  exec(onSuccess, onError, "AppleWatch", "sendNotification", [payload]);
};

// add a few default callbacks, override as you see fit (applewatch.callback.<callbackname> = function() {}
AppleWatch.prototype.callback = {};
// invoked when you've specified invalid UI elements, or in case you omitted a mandatory property
AppleWatch.prototype.callback.onError = function (message) {
  console.log("Error from Watch: " + message);
};
//AppleWatch.prototype.callback.reportIfNotDefined = function(what) {
//  console.log("Please implement the function applewatch.callback." + what + " = function() { your code here }");
//};
//AppleWatch.prototype.callback.updatemain   = AppleWatch.callback.reportIfNotDefined("updatemain");
//AppleWatch.prototype.callback.updatedetail = AppleWatch.callback.reportIfNotDefined("updatedetail");
//AppleWatch.prototype.callback.updateglance = AppleWatch.callback.reportIfNotDefined("updateglance");

module.exports = new AppleWatch();
