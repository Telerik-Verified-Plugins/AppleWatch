var exec = require("cordova/exec");

var AppleWatch = function () {
};

AppleWatch.prototype.init = function (onSuccess, onError, appGroupId) {
  exec(onSuccess, onError, "AppleWatch", "init", [{
        "appGroupId": appGroupId
  }]);
};

AppleWatch.prototype.registerNotifications = function (onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "registerNotifications", []);
};

AppleWatch.prototype.sendMessage = function (payload, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "sendMessage", [{
        "payload": payload
  }]);
};

AppleWatch.prototype.sendNotification = function (onSuccess, onError, payload) {
  exec(onSuccess, onError, "AppleWatch", "sendNotification", [payload]);
};

AppleWatch.prototype.sendUserDefaults = function (onSuccess, onError, obj, appGroupId) {
  var key = Object.keys(obj)[0];
  var payload = {
    "key": key,
    "value": obj[key],
    "appGroupId": appGroupId
  };
  exec(onSuccess, onError, "AppleWatch", "sendUserDefaults", [payload]);
};

AppleWatch.prototype.addListener = function (queueName, onMessage) {
  var wrappedOnMessage = function (message) {
    try {
      message = JSON.parse(message);
    } catch (e) {
    }
    onMessage(message);
  };

  exec(wrappedOnMessage, null, "AppleWatch", "addListener", [{
    "queueName": queueName
  }]);
};

AppleWatch.prototype.removeListener = function (queueName, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "removeListener", [{
    "queueName": queueName
  }]);
};

AppleWatch.prototype.purgeQueue = function (queueName, onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "purgeQueue", [{
    "queueName": queueName
  }]);
};

AppleWatch.prototype.purgeAllQueues = function (onSuccess, onError) {
  exec(onSuccess, onError, "AppleWatch", "purgeAllQueues", []);
};

// add a few default callbacks, override as you see fit (applewatch.callback.<callbackname> = function() {}
AppleWatch.prototype.callback = {};
// invoked when you've specified invalid UI elements, or in case you omitted a mandatory property
AppleWatch.prototype.callback.onError = function(message) {
  console.log("Error from Watch: " + message);
};
//AppleWatch.prototype.callback.reportIfNotDefined = function(what) {
//  console.log("Please implement the function applewatch.callback." + what + " = function() { your code here }");
//};
//AppleWatch.prototype.callback.updatemain   = AppleWatch.callback.reportIfNotDefined("updatemain");
//AppleWatch.prototype.callback.updatedetail = AppleWatch.callback.reportIfNotDefined("updatedetail");
//AppleWatch.prototype.callback.updateglance = AppleWatch.callback.reportIfNotDefined("updateglance");

module.exports = new AppleWatch();
